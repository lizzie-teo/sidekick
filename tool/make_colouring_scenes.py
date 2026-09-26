import math, os
# Draws the six colouring scenes in assets/colouring/.
#
# Run: python3 tool/make_colouring_scenes.py
#
# Every space you can colour is its own closed <path> with its own id, and
# later paths sit on top of earlier ones. The app fills the shapes, so colour
# can never leak through a gap in a line. A scene drawn by hand in Figma
# must keep the same two rules. See _docs/briefs/colouring-book.md.
OUT=os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'colouring')
W,H=800,1000
def f(v): return ('%.1f'%v).rstrip('0').rstrip('.')
def pts(ps): return ' '.join(f'{f(x)},{f(y)}' for x,y in ps)
def poly(ps): return 'M'+pts(ps[:1])+' L'+pts(ps[1:])+' Z'
def rect(x,y,w,h): return poly([(x,y),(x+w,y),(x+w,y+h),(x,y+h)])
def circle(cx,cy,r): return f'M{f(cx-r)},{f(cy)} A{f(r)},{f(r)} 0 1 0 {f(cx+r)},{f(cy)} A{f(r)},{f(r)} 0 1 0 {f(cx-r)},{f(cy)} Z'
def ellipse(cx,cy,rx,ry): return f'M{f(cx-rx)},{f(cy)} A{f(rx)},{f(ry)} 0 1 0 {f(cx+rx)},{f(cy)} A{f(rx)},{f(ry)} 0 1 0 {f(cx-rx)},{f(cy)} Z'
def hill(y0,ctrl,y1,bottom=H+10):
    # a smooth ridge from the left edge to the right edge, closed along the bottom
    d=f'M-10,{f(y0)} '
    xs=[-10]+[c[0] for c in ctrl]+[W+10]
    ys=[y0]+[c[1] for c in ctrl]+[y1]
    for i in range(1,len(xs)):
        mx=(xs[i-1]+xs[i])/2
        d+=f'C{f(mx)},{f(ys[i-1])} {f(mx)},{f(ys[i])} {f(xs[i])},{f(ys[i])} '
    return d+f'L{W+10},{bottom} L-10,{bottom} Z'
def petal(cx,cy,angle,r0,r1,width):
    a=math.radians(angle); ux,uy=math.cos(a),math.sin(a); px,py=-uy,ux
    bx,by=cx+ux*r0,cy+uy*r0; tx,ty=cx+ux*r1,cy+uy*r1
    m=(r0+r1)/2
    c1=(cx+ux*m+px*width, cy+uy*m+py*width); c2=(cx+ux*m-px*width, cy+uy*m-py*width)
    return f'M{f(bx)},{f(by)} Q{f(c1[0])},{f(c1[1])} {f(tx)},{f(ty)} Q{f(c2[0])},{f(c2[1])} {f(bx)},{f(by)} Z'
def star(cx,cy,r,inner=0.45,n=5):
    ps=[]
    for i in range(n*2):
        rr=r if i%2==0 else r*inner
        a=math.radians(-90+i*180/n)
        ps.append((cx+rr*math.cos(a),cy+rr*math.sin(a)))
    return poly(ps)
def pine(cx,top,bottom,width,tiers=3):
    # a slim pine: stacked tiers drawn as one zigzag outline
    h=bottom-top; left=[]; right=[]
    for t in range(tiers):
        ty=top+h*t/tiers*0.8; by=top+h*(t+1)/tiers
        w=width*(0.55+0.45*(t+1)/tiers)/2; step=w*0.45
        right+= [(cx+step*(t>0)*0.6, ty+ (h/tiers*0.15 if t>0 else 0)), (cx+w,by)]
        left = [(cx-w,by),(cx-step*(t>0)*0.6, ty+(h/tiers*0.15 if t>0 else 0))]+left
    ps=[(cx,top)]+right[1:]+[(cx+width*0.12,bottom),(cx-width*0.12,bottom)]+left[:-1]
    return poly(ps)
def trunk(cx,top,bottom,w): return rect(cx-w/2,top,w,bottom-top)
def mountain(peaks,base):
    ps=[(peaks[0][0]-200,base)]+peaks+[(peaks[-1][0]+200,base)]
    return poly(ps)
def write(name,regions):
    ids=set()
    body=[]
    for rid,d in regions:
        assert rid not in ids,rid; ids.add(rid)
        body.append(f'  <path id="{rid}" d="{d}"/>')
    svg=(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" '
         f'fill="none" stroke="#2E2A26" stroke-width="5" stroke-linejoin="round">\n'
         +'\n'.join(body)+'\n</svg>\n')
    open(os.path.join(OUT,name+'.svg'),'w').write(svg)

# 1. Hills at sunrise -- big spaces. No trunks on the big-space scenes: a
# trunk is a thin space, and these pages promise none.
write('sunrise_hills',[
 ('sky',rect(0,0,W,H)),
 ('sun',circle(560,320,110)),
 ('far-hill',hill(560,[(260,470),(560,540)],480)),
 ('near-hill',hill(720,[(300,640),(620,690)],610)),
 ('pine',pine(200,360,800,230)),
 ('slope',hill(880,[(420,820)],760)),
])

# 2. Moon over the valley -- big spaces
write('moon_valley',[
 ('sky',rect(0,0,W,H)),
 ('moon',circle(210,220,95)),
 ('star-1',star(500,140,64)),
 ('star-2',star(670,290,56)),
 ('star-3',star(410,335,54)),
 ('back-mountain',mountain([(160,580),(420,430),(700,560)],820)),
 ('front-mountain',mountain([(40,680),(300,590),(560,720),(760,610)],880)),
 ('ground',hill(900,[(380,870)],850)),
 ('pine',pine(640,480,880,220)),
])

# 3. One big flower -- big spaces
# The leaves go before the stem, so the stem covers where they join it.
fl=[('background',rect(0,0,W,H)),
 ('leaf-left','M395,780 C300,700 190,720 150,760 C230,820 330,830 395,800 Z'),
 ('leaf-right','M420,700 C500,620 610,630 660,670 C590,740 490,750 420,725 Z'),
 ('stem','M360,520 C345,650 395,780 365,1010 L461,1010 C490,780 445,650 456,520 Z')]
for i in range(8):
    fl.append((f'petal-{i+1}',petal(405,380,i*45-90,40,250,95)))
fl.append(('centre',circle(405,380,85)))
write('big_flower',fl)

# 4. Circle pattern (mandala) -- small spaces
cx,cy=400,500
m=[('background',rect(0,0,W,H))]
for i in range(16): m.append((f'outer-petal-{i+1}',petal(cx,cy,i*22.5,190,375,48)))
m.append(('ring',circle(cx,cy,250)))
for i in range(12): m.append((f'middle-petal-{i+1}',petal(cx,cy,i*30+15,70,245,42)))
m.append(('inner-ring',circle(cx,cy,110)))
for i in range(8): m.append((f'small-petal-{i+1}',petal(cx,cy,i*45,25,105,26)))
m.append(('centre',circle(cx,cy,32)))
write('circle_pattern',m)

# 5. Butterfly in the garden -- small spaces
b=[('background',rect(0,0,W,H)),
   ('grass',hill(830,[(250,800),(560,840)],810))]
flowers=[(140,780,70),(400,860,60),(660,770,75)]
for n,(fx,fy,r) in enumerate(flowers,1):
    b.append((f'stem-{n}',rect(fx-8,fy,16,H-fy+10)))
for n,(fx,fy,r) in enumerate(flowers,1):
    for p in range(5): b.append((f'flower-{n}-petal-{p+1}',petal(fx,fy,p*72-90,12,r,r*0.42)))
    b.append((f'flower-{n}-centre',circle(fx,fy,r*0.28)))
bx,by=400,380
b+= [('wing-top-left','M390,360 C300,180 130,170 120,270 C110,370 250,420 390,390 Z'),
     ('wing-top-right','M410,360 C500,180 670,170 680,270 C690,370 550,420 410,390 Z'),
     ('wing-bottom-left','M390,400 C290,410 180,470 210,560 C240,620 350,560 392,430 Z'),
     ('wing-bottom-right','M410,400 C510,410 620,470 590,560 C560,620 450,560 408,430 Z'),
     ('spot-top-left-1',circle(220,275,42)), ('spot-top-left-2',circle(320,330,22)),
     ('spot-top-right-1',circle(580,275,42)), ('spot-top-right-2',circle(480,330,22)),
     ('spot-bottom-left',circle(270,510,30)), ('spot-bottom-right',circle(530,510,30)),
     ('body',ellipse(400,420,20,110)), ('head',circle(400,295,26))]
write('butterfly_garden',b)

# 6. Forest under the mountains -- small spaces
fo=[('sky',rect(0,0,W,H)), ('sun',circle(620,190,70)),
    ('mountain-left',mountain([(230,300)],640)),
    ('mountain-right',mountain([(560,260)],640)),
    ('mountain-middle',mountain([(400,380)],660)),
    ('snow-left',poly([(230,300),(283,369),(255,352),(230,375),(205,352),(177,369)])),
    ('snow-right',poly([(560,260),(617,334),(588,315),(560,340),(532,315),(503,334)])),
    ('hill',hill(620,[(280,570),(560,610)],560))]
trees=[(80,540,760,110),(190,580,800,100),(700,520,770,120),(600,600,820,100),(320,640,860,95),(470,650,880,100),(760,660,900,90)]
for n,(tx,top,bot,wd) in enumerate(trees,1):
    fo.append((f'pine-{n}',pine(tx,top,bot,wd)))
    fo.append((f'trunk-{n}',trunk(tx,bot,bot+40,20)))
fo.append(('meadow',hill(900,[(400,870)],880)))
write('mountain_forest',fo)
print(sorted(os.listdir(OUT)))
