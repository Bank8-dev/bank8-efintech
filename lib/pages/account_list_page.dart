// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech account list — consented accounts from FDX snapshots.
// Account list — capability badges and account data mapping.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../fdx_hooks.dart';
import '../url_router.dart';
import 'account_detail_page.dart';

class AccountListPage extends StatefulWidget {
  final EFintechContext appContext;
  /// Optional consent_id to filter accounts to only those the customer
  /// selected during the consent flow. If null, all accounts are shown.
  final String? consentId;
  const AccountListPage({super.key, required this.appContext, this.consentId});
  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  late FdxAccountsHook _accountsHook;
  @override
  void initState() {
    super.initState();
    // Pass the most recent active consent_id so the FDX recipient API
    // filters accounts to only those the customer selected during the
    // consent flow (fdx_consent_resources).
    _accountsHook = FdxAccountsHook(widget.appContext.services!.fdx, consentId: widget.consentId);
    _accountsHook.fetch();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Accounts', style: Sentin8Text.headlineLarge),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _accountsHook, builder: (_, __) {
            if (_accountsHook.state.isLoading) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
            final accounts = _accountsHook.accounts;
            if (accounts.isEmpty) return const GlassPanel(child: Center(child: Column(children: [Icon(Icons.inbox_outlined, size: 48, color: Sentin8Colors.textSecondary), SizedBox(height: Sentin8Spacing.md), Text('No accounts yet', style: Sentin8Text.headlineMedium)])));
            return Expanded(child: ListView.builder(itemCount: accounts.length, itemBuilder: (context, index) {
              final a = accounts[index];
              final id = a['accountId'] as String? ?? a['id'] as String? ?? '';
              return GestureDetector(onTap: () {
                pushRoute('/accounts/$id');
                Navigator.push(context, MaterialPageRoute(builder: (_) => AccountDetailPage(appContext: widget.appContext, accountId: id, account: a)));
              }, child: _buildCard(a));
            }));
          }),
        ]),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> a) {
    final name = a['nickname'] as String? ?? a['name'] as String? ?? 'Account';
    final type = a['accountType'] as String? ?? '';
    final balance = a['currentBalance'] as num? ?? 0;
    final masked = a['accountNumberDisplay'] as String? ?? '';
    final status = a['status'] as String? ?? 'OPEN';
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
            if (masked.isNotEmpty) Text(masked, style: Sentin8Text.labelSmall),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('\$${balance.toDouble().toStringAsFixed(2)}', style: Sentin8Text.bodyLarge),
            Text(status, style: Sentin8Text.labelSmall),
          ]),
        ]),
      ),
    );
  }

  @override
  void dispose() { _accountsHook.dispose(); super.dispose(); }
}