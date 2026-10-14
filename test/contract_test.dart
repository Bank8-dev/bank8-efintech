// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech contract tests.
import 'package:flutter_test/flutter_test.dart';
import 'package:efintech/services.dart';

void main() {
  group('BffApiClient', () {
    test('FDX client uses correct service name', () {
      final c = BffApiClient(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local', serviceName: 'bank8-fdx');
      expect(c.serviceName, equals('bank8-fdx'));
    });

    test('DB client uses correct service name', () {
      final c = BffApiClient(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local', serviceName: 'db');
      expect(c.serviceName, equals('db'));
    });

    test('Storage client uses correct service name', () {
      final c = BffApiClient(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local', serviceName: 'storage');
      expect(c.serviceName, equals('storage'));
    });
  });

  group('EFintechServices', () {
    test('Creates only 3 service clients (no ledger/payments — read-only recipient)', () {
      final s = EFintechServices(bffBaseUrl: 'https://bff.bank8-efintech.prod.acme.sentin8.local');
      expect(s.fdx.serviceName, equals('bank8-fdx'));
      expect(s.db.serviceName, equals('db'));
      expect(s.storage.serviceName, equals('storage'));
    });
  });

  group('Correlation ID', () {
    test('generateCorrelationId produces non-empty string', () {
      final id = generateCorrelationId();
      expect(id, isNotEmpty);
      // SDK default prefix is 'app' (correlation.dart) — callers pass their
      // own prefix (e.g. eFintech's logger) at call sites.
      expect(id, startsWith('app-'));
    });
  });
}