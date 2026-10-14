// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech transaction list — paginated transaction history from FDX snapshots.
// Transaction list — cursor pagination, date filtering.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../fdx_hooks.dart';

class TransactionListPage extends StatefulWidget {
  final EFintechContext appContext;
  final String accountId;
  const TransactionListPage({super.key, required this.appContext, required this.accountId});
  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late FdxTransactionsHook _txnsHook;
  @override
  void initState() { super.initState(); _txnsHook = FdxTransactionsHook(widget.appContext.services!.fdx, widget.accountId); _txnsHook.fetch(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary), onPressed: () => Navigator.pop(context)), const SizedBox(width: Sentin8Spacing.sm), const Text('Transactions', style: Sentin8Text.headlineLarge)]),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _txnsHook, builder: (_, __) {
            if (_txnsHook.state.isLoading) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
            final txns = _txnsHook.transactions;
            if (txns.isEmpty) return const GlassPanel(child: Center(child: Column(children: [Icon(Icons.receipt_long_outlined, size: 48, color: Sentin8Colors.textSecondary), SizedBox(height: Sentin8Spacing.md), Text('No transactions yet', style: Sentin8Text.headlineMedium)])));
            return Expanded(child: Column(children: [
              Expanded(child: ListView.builder(itemCount: txns.length, itemBuilder: (context, index) {
                return _buildTile(txns[index]);
              })),
              if (_txnsHook.hasMore) Padding(padding: const EdgeInsets.all(Sentin8Spacing.md), child: SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () => _txnsHook.loadMore(), child: const Text('Load More')))),
            ]));
          }),
        ]),
      ),
    );
  }

  Widget _buildTile(Map<String, dynamic> txn) {
    final desc = txn['description'] as String? ?? 'Transaction';
    final amount = txn['amount'] as num? ?? 0;
    final date = txn['postedTimestamp'] as String? ?? txn['date'] as String? ?? '';
    final dc = txn['debitCreditMemo'] as String? ?? 'DEBIT';
    final isDebit = dc == 'DEBIT';
    return ListTile(
      leading: Icon(isDebit ? Icons.arrow_outward : Icons.arrow_downward, color: isDebit ? Sentin8Colors.error : Sentin8Colors.success),
      title: Text(desc, style: Sentin8Text.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(date, style: Sentin8Text.labelSmall),
      trailing: Text('${isDebit ? '-' : '+'}\$${amount.toDouble().toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w600, color: isDebit ? Sentin8Colors.error : Sentin8Colors.success)),
    );
  }

  @override
  void dispose() { _txnsHook.dispose(); super.dispose(); }
}