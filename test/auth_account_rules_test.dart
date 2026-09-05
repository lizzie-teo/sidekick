import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';

// The rules AuthService and AuthStateService both read. They used to hold one
// copy each, the copies drifted, and the app treated an address that had only
// been typed as an account -- which threw the user off the verify screen
// before they could enter the code.
void main() {
  User user({
    String? email,
    String? newEmail,
    String? emailConfirmedAt,
    bool isAnonymous = false,
  }) {
    return User(
      id: 'user-1',
      appMetadata: const <String, dynamic>{},
      userMetadata: const <String, dynamic>{},
      aud: 'authenticated',
      createdAt: '2026-09-05T00:00:00Z',
      email: email,
      newEmail: newEmail,
      emailConfirmedAt: emailConfirmedAt,
      isAnonymous: isAnonymous,
    );
  }

  group('userHasAccount', () {
    test('is false with no user at all', () {
      expect(userHasAccount(null), isFalse);
    });

    test('is false for an anonymous user', () {
      expect(userHasAccount(user(isAnonymous: true)), isFalse);
    });

    // The bug. Supabase writes the address on submit and stamps
    // email_confirmed_at only when the code is entered.
    test('is false while the address is typed but not confirmed', () {
      expect(
        userHasAccount(user(email: 'someone@example.com')),
        isFalse,
      );
    });

    test('is true once the address is confirmed', () {
      expect(
        userHasAccount(user(
          email: 'someone@example.com',
          emailConfirmedAt: '2026-09-05T01:00:00Z',
        )),
        isTrue,
      );
    });
  });

  group('pendingEmailOf', () {
    test('is null with no user at all', () {
      expect(pendingEmailOf(null), isNull);
    });

    test('is null for an account with nothing outstanding', () {
      expect(
        pendingEmailOf(user(
          email: 'someone@example.com',
          emailConfirmedAt: '2026-09-05T01:00:00Z',
        )),
        isNull,
      );
    });

    // Attaching a first address: Supabase puts it in email, unconfirmed.
    test('finds a first address waiting to be confirmed', () {
      expect(
        pendingEmailOf(user(email: 'someone@example.com')),
        'someone@example.com',
      );
    });

    // Changing an existing address: Supabase puts the new one in new_email
    // and leaves the confirmed one in place.
    test('finds an address being changed to', () {
      expect(
        pendingEmailOf(user(
          email: 'old@example.com',
          newEmail: 'new@example.com',
          emailConfirmedAt: '2026-09-05T01:00:00Z',
        )),
        'new@example.com',
      );
    });
  });
}
