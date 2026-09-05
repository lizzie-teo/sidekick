import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The one account ask in the product, shown once, after the first save.
//
// Not on arrival -- that is the 74% who never get past a signup screen. Not on
// a timer either: most people are gone before day seven, so a day-seven ask
// reaches almost nobody. It goes here because a first save is the moment the
// user has something worth keeping, and it is the only moment they can be
// told so honestly.
//
// It is an offer, not a warning. No "you will lose this", and no explanation
// of where the data lives -- nobody should have to learn the difference
// between a phone and an account to use a gratitude app.
//
// Either answer is final. The standing door afterwards is the Me tab, which
// offers an account for as long as there is no email on the account.
class GoodThingsAccountOffer extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const GoodThingsAccountOffer({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  // A sheet rather than a page, so the entry that was just saved stays
  // visible behind it and the ask never reads as a wall.
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.sk.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) => GoodThingsAccountOffer(
        onAccept: onAccept,
        onDecline: onDecline,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Keep these safe?',
              textAlign: TextAlign.center,
              style: SkText.cardTitle.copyWith(color: sk.ink),
            ),
            const SizedBox(height: 10),
            Text(
              'Add an email so you can get these back on a new phone.',
              textAlign: TextAlign.center,
              style: SkText.caption.copyWith(color: sk.muted),
            ),
            const SizedBox(height: 24),
            SkPrimaryButton(label: 'Add an email', onPressed: onAccept),
            const SizedBox(height: 10),
            SkOutlineButton(label: 'Not now', onPressed: onDecline),
          ],
        ),
      ),
    );
  }
}
