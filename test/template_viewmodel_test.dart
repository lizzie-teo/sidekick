import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/features/_template/viewmodels/template_viewmodel.dart';

// Viewmodels take their dependencies by constructor, so they can be tested
// without booting the service locator or the widget tree.
void main() {
  test('init clears loading and leaves no errors', () async {
    final viewModel = TemplateViewModel(loggerService: LoggerService());

    await viewModel.init();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.errors, isEmpty);

    viewModel.dispose();
  });

  test('refresh reports a message without touching page loading state',
      () async {
    final viewModel = TemplateViewModel(loggerService: LoggerService());

    await viewModel.refresh();

    expect(viewModel.state.value.isLoading, isFalse);
    expect(viewModel.state.value.messages['general'], isNotNull);

    viewModel.dispose();
  });
}
