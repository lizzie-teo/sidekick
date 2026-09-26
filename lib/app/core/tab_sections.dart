import 'package:sidekick/app/core/feature_registry.dart';
import 'package:sidekick/app/models/tab_section.dart';

// The parts other features add to a tab, in toggle order.
//
// It walks the registry the way `guidedIntroFor` does, so a tab can show a
// feature's part without importing that feature. A feature that is removed
// takes its parts with it.
List<TabSection> tabSectionsFor(String tab) {
  final List<TabSection> sections = <TabSection>[
    for (final module in featureModules)
      ...?module.tabSections[tab],
  ];
  sections.sort((TabSection a, TabSection b) => a.order.compareTo(b.order));
  return sections;
}
