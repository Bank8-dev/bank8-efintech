// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech dashboard — FdxRecipientSummaryCard showing connected providers and consent summary.
// Dashboard — provider and consent summary.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../fdx_hooks.dart';

class DashboardPage extends StatefulWidget {
  final EFintechContext appContext;
  const DashboardPage({super.key, required this.appContext});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late FdxConsentsHook _consentsHook;
  late FdxAccountsHook _accountsHook;

  @override
  void initState() {
    super.initState();
    _consentsHook = FdxConsentsHook(widget.appContext.services!.fdx);
    _accountsHook = FdxAccountsHook(widget.appContext.services!.fdx);
    _consentsHook.fetch();
    _accountsHook.fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dashboard', style: Sentin8Text.headlineLarge),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _consentsHook, builder: (_, __) {
            final consents = _consentsHook.consents;
            final activeCount = consents.where((c) => c['status'] == 'ACTIVE').length;
            return GlassPanel(
              child: Row(children: [
                Icon(Icons.cloud_done, color: Theme.of(context).colorScheme.primary, size: 40),
                const SizedBox(width: Sentin8Spacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Connected Providers', style: Sentin8Text.labelSmall),
                  Text('$activeCount active', style: Sentin8Text.headlineLarge),
                  Text('${consents.length} total connections', style: Sentin8Text.labelSmall),
                ])),
                IconButton(icon: const Icon(Icons.refresh, color: Sentin8Colors.textSecondary), onPressed: () { _consentsHook.fetch(); _accountsHook.fetch(); }),
              ]),
            );
          }),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _accountsHook, builder: (_, __) {
            if (_accountsHook.state.isLoading) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
            final accounts = _accountsHook.accounts;
            if (accounts.isEmpty) return const GlassPanel(child: Center(child: Column(children: [Icon(Icons.account_balance_outlined, size: 48, color: Sentin8Colors.textSecondary), SizedBox(height: Sentin8Spacing.md), Text('No connected accounts yet', style: Sentin8Text.headlineMedium), SizedBox(height: Sentin8Spacing.xs), Text('Connect a provider to see your accounts.', style: Sentin8Text.bodyMedium)])));
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your Accounts', style: Sentin8Text.headlineMedium),
              const SizedBox(height: Sentin8Spacing.md),
              ...accounts.map((a) => _buildAccountCard(a)),
            ]);
          }),
        ]),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final name = account['nickname'] as String? ?? account['name'] as String? ?? 'Account';
    final type = account['accountType'] as String? ?? '';
    final balance = account['currentBalance'] as num? ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: Sentin8Spacing.sm),
      child: GlassPanel(
        padding: const EdgeInsets.all(Sentin8Spacing.md),
        child: Row(children: [
          Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: Sentin8Spacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: Sentin8Text.bodyLarge),
            if (type.isNotEmpty) Text(type, style: Sentin8Text.labelSmall),
          ])),
          Text('\$${balance.toDouble().toStringAsFixed(2)}', style: Sentin8Text.bodyLarge),
        ]),
      ),
    );
  }

  @override
  void dispose() { _consentsHook.dispose(); _accountsHook.dispose(); super.dispose(); }
}