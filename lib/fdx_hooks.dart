// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech FDX hooks — FDX Data Recipient API access via BFF proxy.
// eFintech is an FDX Data Recipient — it consumes external provider data
// through FDX. All calls go through BFF → FDX recipient API
// (/v1/recipient/...).
import 'package:flutter/foundation.dart';
import 'services.dart';

class DataState<T> {
  final T? data;
  final bool isLoading;
  final String? error;
  const DataState({this.data, this.isLoading = false, this.error});
  bool get hasData => data != null;
}

/// useFdxProviders — fetch FDX recipient provider catalog.
/// Providers via BFF → FDX GET /v1/recipient/providers.
class FdxProvidersHook extends ChangeNotifier {
  final BffApiClient fdx;
  DataState<List<Map<String, dynamic>>> _state = const DataState();
  FdxProvidersHook(this.fdx);
  DataState<List<Map<String, dynamic>>> get state => _state;
  List<Map<String, dynamic>> get providers => _state.data ?? [];

  Future<void> fetch() async {
    _state = const DataState(isLoading: true); notifyListeners();
    try {
      final response = await fdx.get('/v1/recipient/providers');
      if (response.isSuccess && response.data != null) {
        final providers = (response.data!['providers'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
        _state = DataState(data: providers);
      } else { _state = const DataState(data: []); }
    } catch (e) { _state = DataState(error: e.toString()); }
    notifyListeners();
  }
}

/// useFdxConsents — fetch customer's FDX consents (as a data recipient's customer).
/// Consents via BFF → FDX GET /v1/recipient/consents.
class FdxConsentsHook extends ChangeNotifier {
  final BffApiClient fdx;
  DataState<List<Map<String, dynamic>>> _state = const DataState();
  FdxConsentsHook(this.fdx);
  DataState<List<Map<String, dynamic>>> get state => _state;
  List<Map<String, dynamic>> get consents => _state.data ?? [];

  Future<void> fetch() async {
    _state = const DataState(isLoading: true); notifyListeners();
    try {
      final response = await fdx.get('/v1/recipient/consents');
      if (response.isSuccess && response.data != null) {
        final consents = (response.data!['consents'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
        _state = DataState(data: consents);
      } else { _state = const DataState(data: []); }
    } catch (e) { _state = DataState(error: e.toString()); }
    notifyListeners();
  }

  /// Start a consent flow.
  Future<String?> startConsent(Map<String, dynamic> request) async {
    final idempotencyKey = 'cs-${DateTime.now().millisecondsSinceEpoch}';
    try {
      final response = await fdx.post('/v1/recipient/consents/start', body: {...request, 'idempotencyKey': idempotencyKey});
      if (response.isSuccess && response.data != null) {
        return response.data!['redirectUrl'] as String? ??
            response.data!['authorization_url'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Revoke a consent.
  Future<bool> revoke(String consentId, {String reason = 'USER_ACTION'}) async {
    final idempotencyKey = 'rvk-${DateTime.now().millisecondsSinceEpoch}';
    try {
      final response = await fdx.post('/v1/recipient/consents/$consentId/revoke', body: {'reason': reason, 'idempotencyKey': idempotencyKey});
      if (response.isSuccess) { await fetch(); return true; }
    } catch (_) {}
    return false;
  }

  /// Trigger data refresh.
  Future<bool> refresh(String consentId) async {
    try {
      final response = await fdx.post('/v1/recipient/consents/$consentId/refresh', body: {});
      return response.isSuccess;
    } catch (_) { return false; }
  }
}

/// useFdxAccounts — fetch consented accounts from FDX snapshots.
/// Accounts via BFF → FDX GET /v1/recipient/accounts.
/// If consentId is provided, only the accounts the customer selected
/// during the consent flow are returned (fdx_consent_resources filter).
class FdxAccountsHook extends ChangeNotifier {
  final BffApiClient fdx;
  final String? consentId;
  DataState<List<Map<String, dynamic>>> _state = const DataState();
  FdxAccountsHook(this.fdx, {this.consentId});
  DataState<List<Map<String, dynamic>>> get state => _state;
  List<Map<String, dynamic>> get accounts => _state.data ?? [];

  Future<void> fetch() async {
    _state = const DataState(isLoading: true); notifyListeners();
    try {
      final path = consentId != null
          ? '/v1/recipient/accounts?consent_id=$consentId'
          : '/v1/recipient/accounts';
      final response = await fdx.get(path);
      if (response.isSuccess && response.data != null) {
        final accounts = (response.data!['accounts'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
        _state = DataState(data: accounts);
      } else { _state = const DataState(data: []); }
    } catch (e) { _state = DataState(error: e.toString()); }
    notifyListeners();
  }
}

/// useFdxTransactions — fetch transaction history for an account from FDX snapshots.
/// Transactions via BFF → FDX GET /v1/recipient/accounts/{id}/transactions.
class FdxTransactionsHook extends ChangeNotifier {
  final BffApiClient fdx;
  final String accountId;
  DataState<List<Map<String, dynamic>>> _state = const DataState();
  String? _nextPageKey;
  List<Map<String, dynamic>> _all = [];

  FdxTransactionsHook(this.fdx, this.accountId);
  DataState<List<Map<String, dynamic>>> get state => _state;
  List<Map<String, dynamic>> get transactions => _all;
  bool get hasMore => _nextPageKey != null;

  Future<void> fetch({DateTime? startDate, DateTime? endDate}) async {
    _state = const DataState(isLoading: true); notifyListeners();
    _all = []; _nextPageKey = null;
    try {
      final params = <String, String>{};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();
      final response = await fdx.get('/v1/recipient/accounts/$accountId/transactions', queryParams: params.isNotEmpty ? params : null);
      if (response.isSuccess && response.data != null) {
        final txns = (response.data!['transactions'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
        _all = txns; _nextPageKey = response.data!['nextPageKey'] as String?;
        _state = DataState(data: _all);
      } else { _state = const DataState(data: []); }
    } catch (e) { _state = DataState(error: e.toString()); }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_nextPageKey == null) return;
    try {
      final response = await fdx.get('/v1/recipient/accounts/$accountId/transactions', queryParams: {'pageKey': _nextPageKey!});
      if (response.isSuccess && response.data != null) {
        final txns = (response.data!['transactions'] as List<dynamic>?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
        _all = [..._all, ...txns]; _nextPageKey = response.data!['nextPageKey'] as String?;
        _state = DataState(data: _all); notifyListeners();
      }
    } catch (_) {}
  }
}