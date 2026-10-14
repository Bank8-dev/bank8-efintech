// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech account detail — full account details with transaction link.
// Account detail screen — EFintechAccount DTO mapping.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../url_router.dart';
import 'transaction_list_page.dart';

class AccountDetailPage extends StatelessWidget {
  final EFintechContext appContext;
  final String accountId;
  final Map<String, dynamic> account;
  const AccountDetailPage({super.key, required this.appContext, required this.accountId, required this.account});

  @override
  Widget build(BuildContext context) {
    final name = account['nickname'] as String? ?? account['name'] as String? ?? 'Account';
    final type = account['accountType'] as String? ?? '';
    final balance = account['currentBalance'] as num? ?? 0;
    final available = account['availableBalance'] as num?;
    final rate = account['interestRate'];
    final limit = account['creditLimit'];
    final nextPayment = account['nextPaymentDate'];
    final nextAmount = account['nextPaymentAmount'];
    final masked = account['accountNumberDisplay'] as String? ?? '';

    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary), onPressed: () { navigateTo('/accounts'); Navigator.pop(context); }), const SizedBox(width: Sentin8Spacing.sm), Expanded(child: Text(name, style: Sentin8Text.headlineLarge))]),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(child: Row(children: [Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary, size: 40), const SizedBox(width: Sentin8Spacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Current Balance', style: Sentin8Text.labelSmall), Text('\$${balance.toDouble().toStringAsFixed(2)}', style: Sentin8Text.headlineLarge), if (available != null) Text('Available: \$${available.toDouble().toStringAsFixed(2)}', style: Sentin8Text.labelSmall)]))])),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Account Details', style: Sentin8Text.headlineMedium),
            const SizedBox(height: Sentin8Spacing.md),
            if (type.isNotEmpty) _row('Type', type),
            if (masked.isNotEmpty) _row('Account Number', masked),
            _row('Status', account['status'] as String? ?? 'OPEN'),
            if (rate != null) _row('Interest Rate', '$rate%'),
            if (limit != null) _row('Credit Limit', '\$$limit'),
            if (nextPayment != null) _row('Next Payment Date', '$nextPayment'),
            if (nextAmount != null) _row('Next Payment Amount', '\$$nextAmount'),
          ])),
          const SizedBox(height: Sentin8Spacing.lg),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { pushRoute('/accounts/$accountId/transactions'); Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionListPage(appContext: appContext, accountId: accountId))); }, child: const Text('View Transactions'))),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: Sentin8Spacing.xs), child: Row(children: [SizedBox(width: 160, child: Text(label, style: Sentin8Text.labelSmall)), Expanded(child: Text(value, style: Sentin8Text.bodyMedium))]));
}