import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/service_locator.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_invite_card.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';
import 'package:sidekick/data/services/good_things_service.dart';
import 'package:sidekick/features/good_things/models/good_things_day.dart';
import 'package:sidekick/features/good_things/viewmodels/good_things_history_viewmodel.dart';
import 'package:sidekick/features/good_things/widgets/good_things_day_group.dart';
import 'package:sidekick/features/good_things/widgets/good_things_month_switcher.dart';
import 'package:sidekick/features/good_things/widgets/good_things_year_ago_card.dart';

// History -- everything noticed, a month at a time, grouped by day.
//
// No streak, no chart with gaps in it, no comparison against last month. A
// quiet month would read as a failed test, which is the opposite of what
// noticing good things is for.
//
// Reached from the entry form rather than from the tab bar, so it has a back
// arrow and no tab bar of its own.
class GoodThingsHistoryView extends StatefulWidget {
  const GoodThingsHistoryView({super.key});

  @override
  State<GoodThingsHistoryView> createState() => _GoodThingsHistoryViewState();
}

class _GoodThingsHistoryViewState extends State<GoodThingsHistoryView> {
  late final GoodThingsHistoryViewModel _viewModel =
      GoodThingsHistoryViewModel(
    loggerService: getIt<LoggerService>(),
    goodThingsService: getIt<GoodThingsService>(),
    authStateService: getIt<AuthStateService>(),
  );

  // Read once per build of the list, so every day heading on screen agrees
  // about what "Today" means.
  final DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _goConnect() {
    if (GoRouter.maybeOf(context) == null) return;
    context.push(Routes.connect);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sk.canvas,
        surfaceTintColor: sk.canvas,
        elevation: 0,
        title: Text(
          'Good things',
          style: SkText.cardTitle.copyWith(color: sk.ink),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<GoodThingsHistoryViewModelState>(
          valueListenable: _viewModel.state,
          builder: (BuildContext context,
              GoodThingsHistoryViewModelState state, Widget? child) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: <Widget>[
                //

                GoodThingsMonthSwitcher(
                  month: state.month,
                  canShowNext: state.canShowNextMonth,
                  onPrevious: _viewModel.showPreviousMonth,
                  onNext: _viewModel.showNextMonth,
                ),

                // A true statement sitting in the one screen where it is
                // relevant. It never blocks anything and it never pops up.
                if (!state.hasAccount) ...<Widget>[
                  const SizedBox(height: 8),
                  _QuietAccountLine(onTap: _goConnect),
                ],

                if (state.errors['general'] != null) ...<Widget>[
                  const SizedBox(height: 24),
                  Text(
                    state.errors['general']!,
                    textAlign: TextAlign.center,
                    style: SkText.caption.copyWith(color: sk.destructive),
                  ),
                ],

                if (state.yearAgo.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 16),
                  GoodThingsYearAgoCard(entries: state.yearAgo),
                ],

                const SizedBox(height: 20),

                // Warm, and only ever a count. No target to hit and nothing
                // to compare it against.
                Text(
                  _totalLine(state),
                  style: SkText.cardTitle.copyWith(color: sk.ink),
                ),

                const SizedBox(height: 16),

                if (state.days.isEmpty && state.errors.isEmpty)
                  SkInviteCard(
                    title: 'Note the first one',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),

                for (final GoodThingsDay group in state.days) ...<Widget>[
                  GoodThingsDayGroup(group: group, now: _now),
                  const SizedBox(height: 20),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // "You noticed 23 good things this month." Nothing here says a number is
  // low, and nothing says what last month held.
  String _totalLine(GoodThingsHistoryViewModelState state) {
    final bool isThisMonth = !state.canShowNextMonth;
    final String when = isThisMonth ? 'this month' : 'that month';

    if (state.total == 0) {
      return isThisMonth
          ? 'Nothing noted this month yet.'
          : 'Nothing noted that month.';
    }

    if (state.total == 1) {
      return 'You noticed one good thing $when.';
    }

    return 'You noticed ${state.total} good things $when.';
  }
}

// The quiet line from the plan, and nothing more than a line: no card, no
// dismiss, no icon. It is shown whenever the account has no email on it.
class _QuietAccountLine extends StatelessWidget {
  final VoidCallback onTap;

  const _QuietAccountLine({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'No email on this account. Add one to keep these safe.',
            style: SkText.caption.copyWith(color: sk.muted, fontSize: 14),
          ),
        ),
        SkTextButton(label: 'Add', onPressed: onTap),
      ],
    );
  }
}
