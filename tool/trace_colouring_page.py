# Turns a black-and-white colouring page (a PNG or JPG) into a scene the app
# can fill: every space a closed shape with its own id, plus the picture's
# own lines as one layer drawn on top.
#
# Run:
#   python3 tool/trace_colouring_page.py assets/colouring/_source/japanese_garden.jpg japanese_garden
#
# Writes assets/colouring/<name>.svg, and a preview with every space in a
# random colour to /tmp/<name>_preview.png, for checking by eye.
#
# How it works:
#
# | Step | Why |
# | --- | --- |
# | Enlarge 3x, then split every dot into line or paper | Smooth edges from a small source |
# | Crop to the drawing, and stretch any line that ends near the edge out to it | An artist's lines stop a little short of the edge, and each gap would join the spaces either side. A band round the whole page was tried first and cut the sky into blocks |
# | Join each loose line end to a different line close by, and draw the join | A pond bank that stops a hair short of the bridge post would make pond and grass one space |
# | Thicken the lines a little, for finding spaces only | Seals hairline gaps so one tap does not fill two spaces |
# | Each closed white area is a space | The thing a tap fills |
# | Spaces too small for a pen are joined to their biggest neighbour | A speck of paper in a coloured area looks like a mistake |
# | Every line dot goes to its nearest space | The fill tucks under the lines, so no white rim shows between colour and line |
# | The original lines become one layer, drawn last | The page keeps the artist's own thick and thin lines |
#
# Needs: opencv-python, numpy, scipy, scikit-image.

import os
import random
import sys

import cv2
import numpy as np
from scipy import ndimage
from skimage.morphology import skeletonize

SCALE = 3
THRESHOLD = 150        # darker than this is line
GAP_SEAL = 2           # dots the lines grow by when finding spaces
EDGE_REACH = 40        # source dots: a line ending this near the edge is stretched to it
REACH = 5              # source dots: a loose line end this close to another line is joined to it
MIN_SPACE = 22         # in page units: narrower spaces are joined to a neighbour
SIMPLIFY = 0.8         # dots a traced edge may move when it is tidied
PAGE_WIDTH = 900       # the page's width in scene units


def main(source, name):
    grey = cv2.imread(source, cv2.IMREAD_GRAYSCALE)
    if grey is None:
        sys.exit(f'cannot read {source}')

    grey = cv2.resize(grey, None, fx=SCALE, fy=SCALE,
                      interpolation=cv2.INTER_CUBIC)
    lines = grey < THRESHOLD

    # Crop to the drawing, with a little air.
    ys, xs = np.nonzero(lines)
    pad = 0
    top, bottom = max(ys.min() - pad, 0), min(ys.max() + pad, lines.shape[0])
    left, right = max(xs.min() - pad, 0), min(xs.max() + pad, lines.shape[1])
    lines = lines[top:bottom, left:right]
    h, w = lines.shape
    units = PAGE_WIDTH / w  # scene units per dot

    joins = join_loose_ends(lines)
    print(f'joined {joins} loose line end(s)')

    # Spaces: white areas once the lines are thickened and the page framed.
    sealed = cv2.dilate(lines.astype(np.uint8),
                        np.ones((2 * GAP_SEAL + 1,) * 2, np.uint8)) > 0
    # The page's own edge closes every space that reaches it.
    sealed[0, :] = sealed[-1, :] = sealed[:, 0] = sealed[:, -1] = True
    labels, count = ndimage.label(~sealed)

    # Join spaces too small to colour into their biggest neighbour.
    min_dots = (MIN_SPACE / units) ** 2
    sizes = ndimage.sum(np.ones_like(labels), labels, range(count + 1))
    for small in [i for i in range(1, count + 1) if sizes[i] < min_dots]:
        mask = labels == small
        ring = cv2.dilate(mask.astype(np.uint8), np.ones((9, 9), np.uint8)) > 0
        around = labels[ring & ~mask]
        around = around[(around > 0) & (sizes[around] >= min_dots)]
        labels[mask] = np.bincount(around).argmax() if around.size else 0

    # Every dot not in a space -- lines, seals, orphans -- goes to its
    # nearest space.
    _, (iy, ix) = ndimage.distance_transform_edt(labels == 0,
                                                 return_indices=True)
    labels = labels[iy, ix]

    kept = [i for i in np.unique(labels) if i > 0]
    # Painted biggest first: the order does not matter for spaces that do not
    # overlap, but it keeps the file readable -- the sky comes first.
    kept.sort(key=lambda i: -int((labels == i).sum()))

    paths = []
    for n, i in enumerate(kept, 1):
        d = trace((labels == i).astype(np.uint8), units)
        if d:
            paths.append((f'space-{n}', d))

    line_d = trace(lines.astype(np.uint8), units)

    vw, vh = PAGE_WIDTH, round(h * units, 1)
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                       'assets', 'colouring', f'{name}.svg')
    with open(out, 'w') as f:
        f.write(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {vw} {vh}" '
                f'fill-rule="evenodd">\n')
        for pid, d in paths:
            f.write(f'  <path id="{pid}" fill="none" stroke="#999" d="{d}"/>\n')
        f.write(f'  <path id="lines" class="lines" fill="#2E2A26" d="{line_d}"/>\n')
        f.write('</svg>\n')

    preview(labels, kept, lines, f'/tmp/{name}_preview.png')
    print(f'{out}: {len(paths)} spaces, page {vw} x {vh}')


def join_loose_ends(lines):
    # A loose end is a point on the line's centre with one neighbour. It is
    # joined to the nearest line dot within REACH that belongs to a different
    # stroke *locally* -- so a grass tuft's blades, which meet at their base,
    # are left alone, and a bank that stops short of a post is closed.
    reach = REACH * SCALE
    skeleton = skeletonize(lines)
    neighbours = cv2.filter2D(skeleton.astype(np.uint8), -1,
                              np.ones((3, 3), np.float32)) - skeleton
    ends = np.argwhere(skeleton & (neighbours == 1))

    # How thick a line is, so a join looks like the lines around it.
    thickness = max(2, int(np.median(
        ndimage.distance_transform_edt(lines)[skeleton]) * 2))

    joins = 0
    h, w = lines.shape
    edge_reach = EDGE_REACH * SCALE
    for y, x in ends:
        # Near the edge: stretch straight out to it.
        gaps = {(0, x): y, (h - 1, x): h - 1 - y, (y, 0): x, (y, w - 1): w - 1 - x}
        (ey, ex), gap = min(gaps.items(), key=lambda kv: kv[1])
        if gap <= edge_reach and heads_toward(skeleton, y, x, ey, ex):
            cv2.line(lines.view(np.uint8), (int(x), int(y)), (int(ex), int(ey)),
                     1, thickness)
            joins += 1
            continue

        y0, y1 = max(y - reach, 0), min(y + reach + 1, h)
        x0, x1 = max(x - reach, 0), min(x + reach + 1, w)
        window = lines[y0:y1, x0:x1]
        local, _ = ndimage.label(window)
        own = local[y - y0, x - x0]
        if own == 0:
            continue
        others = np.argwhere((local > 0) & (local != own))
        if others.size == 0:
            continue
        d = np.hypot(others[:, 0] - (y - y0), others[:, 1] - (x - x0))
        if d.min() > reach:
            continue
        ty, tx = others[d.argmin()]
        cv2.line(lines.view(np.uint8), (int(x), int(y)),
                 (int(tx + x0), int(ty + y0)), 1, thickness)
        joins += 1
    return joins


def heads_toward(skeleton, y, x, ty, tx):
    # Whether the stroke ending at (y, x) is travelling toward (ty, tx). A
    # bump on a closed outline near the edge also looks like a loose end,
    # and stretching it would draw a line nobody drew.
    r = 8 * SCALE
    patch = np.argwhere(skeleton[max(y - r, 0):y + r + 1,
                                 max(x - r, 0):x + r + 1])
    if len(patch) < 3:
        return False
    cy = patch[:, 0].mean() + max(y - r, 0)
    cx = patch[:, 1].mean() + max(x - r, 0)
    dy, dx = y - cy, x - cx
    wy, wx = ty - y, tx - x
    norm = np.hypot(dy, dx) * np.hypot(wy, wx)
    return norm > 0 and (dy * wy + dx * wx) / norm > 0.6


def trace(mask, units):
    contours, _ = cv2.findContours(mask, cv2.RETR_CCOMP,
                                   cv2.CHAIN_APPROX_NONE)
    parts = []
    for c in contours:
        c = cv2.approxPolyDP(c, SIMPLIFY, True)
        if len(c) < 3:
            continue
        pts = [f'{p[0][0] * units:.1f},{p[0][1] * units:.1f}' for p in c]
        parts.append('M' + ' L'.join(pts) + ' Z')
    return ' '.join(parts)


def preview(labels, kept, lines, path):
    random.seed(1)
    image = np.full(labels.shape + (3,), 255, np.uint8)
    for i in kept:
        image[labels == i] = [random.randint(90, 250) for _ in range(3)]
    image[lines] = (38, 42, 46)
    cv2.imwrite(path, cv2.resize(image, None, fx=1 / SCALE, fy=1 / SCALE,
                                 interpolation=cv2.INTER_AREA))


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
