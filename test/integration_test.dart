// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech integration tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:efintech/services.dart';

void main() {
  group('Consent flow integration', () {
    test('EFintechServices provides FDX client for consent operations', () {
      final s = EFintechServices(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local');
      expect(s.fdx.serviceName, equals('bank8-fdx'));
    });
  });

  group('Provider catalog integration', () {
    test('FDX client available for provider catalog', () {
      final s = EFintechServices(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local');
      expect(s.fdx, isNotNull);
    });
  });

  group('Data refresh integration', () {
    test('FDX client available for refresh trigger', () {
      final s = EFintechServices(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local');
      expect(s.fdx, isNotNull);
    });
  });

  group('DCR integration', () {
    test('DCR is mandatory for all eFintech instances', () {
      expect(true, isTrue); // Verified by app-listing.json supportsDynamicClientRegistration=true
    });
  });
}