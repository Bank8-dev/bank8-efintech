// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech app shell — navigation between providers, consents, accounts, admin.
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;
import '../theme.dart';
import '../app_context.dart';
import '../auth_provider.dart';
import '../url_router.dart';
import 'landing_page.dart';
import 'dashboard_page.dart';
import 'provider_catalog_page.dart';
import 'consent_dashboard_page.dart';
import 'account_list_page.dart';
import '../fdx_hooks.dart';
import 'admin/admin_dashboard_page.dart';
import 'admin/admin_fdx_page.dart';

class EFintechShell extends StatefulWidget {
  const EFintechShell({super.key});
  @override
  State<EFintechShell> createState() => _EFintechShellState();
}

class _EFintechShellState extends State<EFintechShell> {
  String _route = '/';
  EFintechContext? _cached;

  @override
  void initState() {
    super.initState();
    _route = currentRoute();
    if (kIsWeb) {
      web.window.onPopState.listen((_) {
        if (mounted) setState(() { _route = currentRoute(); });
      });
    }
  }

  void _navigate(String route) {
    setState(() => _route = route);
    navigateTo(route);
  }
  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appContext = EFintechContextProvider.of(context);
    if (appContext == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_cached != appContext) {
      _cached?.auth.removeListener(_onAuthChanged);
      _cached = appContext;
      appContext.auth.addListener(_onAuthChanged);
    }

    if (!appContext.auth.isSignedIn) return LandingPage(appContext: appContext);

    // eFintech admin surfaces are guarded by the app-declared
    // `efintech:admin` role-marker scope. That scope is granted
    // exclusively to members of the `efintech-admin` role, which App
    // provisions in `auth_roles` when the listing is installed in a
    // target org/env. Exact match (not substring) — substring would
    // false-positive on `fdx:admin` held by data recipients.
    final isAdmin =
        appContext.auth.state.scopes.contains('efintech:admin');

    Widget content;
    switch (_route) {
      case '/':
        content = DashboardPage(appContext: appContext);
        break;
      case '/providers':
        content = ProviderCatalogPage(appContext: appContext);
        break;
      case '/consents':
        content = ConsentDashboardPage(appContext: appContext);
        break;
      case '/accounts':
        // Pass the most recent active consent_id so the account list
        // is filtered to only the accounts the customer selected during
        // the consent flow (fdx_consent_resources).
        content = AccountListPage(appContext: appContext, consentId: _latestConsentId(appContext));
        break;
      case '/admin':
        content = isAdmin
            ? AdminDashboardPage(appContext: appContext)
            : const _AccessDenied();
        break;
      case '/admin/fdx':
        content = isAdmin
            ? AdminFdxPage(appContext: appContext)
            : const _AccessDenied();
        break;
      default:
        content = DashboardPage(appContext: appContext);
    }

    return Scaffold(
      body: Row(children: [
        _buildSidebar(appContext, isAdmin),
        const VerticalDivider(width: 1, color: Sentin8Colors.border),
        Expanded(child: content),
      ]),
    );
  }

  Widget _buildSidebar(EFintechContext ctx, bool isAdmin) {
    final appName = ctx.runtimeContext.displayName;
    final logoUrl = ctx.runtimeContext.logoIconUrl.isNotEmpty
        ? ctx.runtimeContext.logoIconUrl
        : ctx.runtimeContext.logoUrl;
    return Container(
      width: 240,
      color: Sentin8Colors.surface,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(Sentin8Spacing.lg),
          child: Row(children: [
            if (logoUrl.isNotEmpty)
              networkLogo(
                logoUrl,
                size: 28,
                fallbackWidget: Icon(Icons.connecting_airports,
                    color: Theme.of(context).colorScheme.primary, size: 28),
              )
            else
              Icon(Icons.connecting_airports,
                  color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(width: Sentin8Spacing.sm),
            Expanded(
                child: Text(appName,
                    style: Sentin8Text.headlineMedium,
                    overflow: TextOverflow.ellipsis)),
          ]),
        ),
        const Divider(),
        _nav('Dashboard', '/', Icons.dashboard_outlined),
        _nav('Providers', '/providers', Icons.business_outlined),
        _nav('Connections', '/consents', Icons.link_outlined),
        _nav('Accounts', '/accounts', Icons.account_balance_outlined),
        if (isAdmin) ...[
          const Divider(),
          _nav('Admin', '/admin', Icons.admin_panel_settings_outlined),
          _nav('Admin: FDX', '/admin/fdx', Icons.shield_outlined)
        ],
        Spacer(),
        Divider(),
        ListTile(
          leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                  _avatarInitial(ctx.auth.user),
                  style: const TextStyle(color: Colors.white))),
          title: Text(
              ctx.auth.user?.displayName ?? ctx.auth.user?.email ?? 'User',
              style: Sentin8Text.bodyMedium),
          trailing: IconButton(
              icon: const Icon(Icons.logout, color: Sentin8Colors.textSecondary),
              onPressed: () => ctx.auth.signOut(),
              tooltip: 'Sign Out'),
        ),
      ]),
    );
  }

  Widget _nav(String label, String route, IconData icon) {
    final active = _route == route;
    return ListTile(
      leading: Icon(icon,
          color: active ? Theme.of(context).colorScheme.primary : Sentin8Colors.textSecondary),
      title: Text(label,
          style: TextStyle(
              color: active ? Theme.of(context).colorScheme.primary : Sentin8Colors.textPrimary,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      selected: active,
      selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      onTap: () => _navigate(route),
    );
  }

  @override
  void dispose() {
    _cached?.auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}

/// Initial for the sidebar avatar. Falls back to `'?'` when the BFF
/// session omits `displayName`/`email` (both can be empty strings), so we
/// never index an empty string — see the matching guard in eBank's shell.
String _avatarInitial(EFintechUser? user) {
  final display = user?.displayName;
  if (display != null && display.isNotEmpty) return display[0].toUpperCase();
  final email = user?.email;
  if (email != null && email.isNotEmpty) return email[0].toUpperCase();
  return '?';
}

/// Resolve the most recent active consent_id from the FDX consents hook
/// so the account list page can filter to only consented accounts.
String? _latestConsentId(EFintechContext ctx) {
  try {
    final hook = FdxConsentsHook(ctx.services!.fdx);
    // Synchronously check if consents were already fetched by the
    // consent dashboard. If not, return null (all accounts shown).
    final consents = hook.consents;
    if (consents.isEmpty) return null;
    // Find the most recent active consent.
    final active = consents.where((c) =>
        (c['status'] as String?)?.toLowerCase() == 'active').toList();
    if (active.isEmpty) return null;
    active.sort((a, b) {
      final aTime = a['created_at'] ?? a['createdAt'] ?? '';
      final bTime = b['created_at'] ?? b['createdAt'] ?? '';
      return bTime.toString().compareTo(aTime.toString());
    });
    return active.first['id']?.toString();
  } catch (_) {
    return null;
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.lock_outline, size: 48, color: Sentin8Colors.error),
      SizedBox(height: Sentin8Spacing.md),
      Text('Access Denied', style: Sentin8Text.headlineMedium),
      SizedBox(height: Sentin8Spacing.sm),
      Text('You do not have permission to access this page.',
          style: Sentin8Text.bodyMedium)
    ])));
  }
}
