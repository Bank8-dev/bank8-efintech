// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech services — BFF proxy access layer for FDX, DB, Storage.
//
// BffApiClient, ApiResponse, and generateCorrelationId are re-exported
// from sentin8. EFintechServices is app-specific.

// Re-export shared types from the package.
export 'package:sentin8/sentin8.dart'
    show BffApiClient, ApiResponse, generateCorrelationId;

import 'package:sentin8/sentin8.dart';

/// Centralized service registry for eFintech.
class EFintechServices {
  final BffApiClient fdx;
  final BffApiClient db;
  final BffApiClient storage;

  EFintechServices._({required this.fdx, required this.db, required this.storage});

  factory EFintechServices({
    required String bffBaseUrl,
    String? csrfToken,
    String? correlationId,
  }) {
    final base = bffBaseUrl.replaceAll(RegExp(r'/+$'), '');
    return EFintechServices._(
      fdx: BffApiClient(bffBaseUrl: base, serviceName: 'bank8-fdx', csrfToken: csrfToken, correlationId: correlationId),
      db: BffApiClient(bffBaseUrl: base, serviceName: 'db', csrfToken: csrfToken, correlationId: correlationId),
      storage: BffApiClient(bffBaseUrl: base, serviceName: 'storage', csrfToken: csrfToken, correlationId: correlationId),
    );
  }
}