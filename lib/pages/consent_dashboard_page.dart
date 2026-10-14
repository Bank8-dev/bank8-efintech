// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech consent dashboard — view all active consents, revoke, reauthorize.
// Consent dashboard — status badge, revocation, refresh.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../fdx_hooks.dart';

class ConsentDashboardPage extends StatefulWidget {
  final EFintechContext appContext;
  const ConsentDashboardPage({super.key, required this.appContext});
  @override
  State<ConsentDashboardPage> createState() => _ConsentDashboardPageState();
}

class _ConsentDashboardPageState extends State<ConsentDashboardPage> {
  late FdxConsentsHook _consentsHook;
  @override
  void initState() { super.initState(); _consentsHook = FdxConsentsHook(widget.appContext.services!.fdx); _consentsHook.fetch(); }

  Future<void> _revoke(String consentId) async {
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Revoke Consent'),
      content: const Text('This will immediately revoke data access. The provider will no longer be able to access your data.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), style: TextButton.styleFrom(foregroundColor: Sentin8Colors.error), child: const Text('Revoke'))],
    ));
    if (confirmed != true) return;
    final success = await _consentsHook.revoke(consentId);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Consent revoked' : 'Failed to revoke'), backgroundColor: success ? Sentin8Colors.success : Sentin8Colors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Data Connections', style: Sentin8Text.headlineLarge),
          const SizedBox(height: Sentin8Spacing.sm),
          const Text('Manage your connected data providers.', style: Sentin8Text.bodyMedium),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _consentsHook, builder: (_, __) {
            if (_consentsHook.state.isLoading) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
            final consents = _consentsHook.consents;
            if (consents.isEmpty) return const GlassPanel(child: Center(child: Column(children: [Icon(Icons.link_off, size: 48, color: Sentin8Colors.textSecondary), SizedBox(height: Sentin8Spacing.md), Text('No data connections yet', style: Sentin8Text.headlineMedium), SizedBox(height: Sentin8Spacing.xs), Text('Connect a provider to get started.', style: Sentin8Text.bodyMedium)])));
            return Expanded(child: ListView.builder(itemCount: consents.length, itemBuilder: (context, index) => _buildConsentCard(consents[index])));
          }),
        ]),
      ),
    );
  }

  Widget _buildConsentCard(Map<String, dynamic> consent) {
    final providerName = consent['dataProviderName'] as String? ?? 'Provider';
    final status = consent['status'] as String? ?? 'ACTIVE';
    final consentId = consent['consentId'] as String? ?? consent['id'] as String? ?? '';
    final createdAt = consent['createdAt'] as String? ?? '';
    final expiresAt = consent['expiresAt'] as String?;
    final isActive = status == 'ACTIVE';
    final scopes = (consent['scopes'] as List<dynamic>?)?.cast<String>() ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: Sentin8Spacing.sm),
      child: GlassPanel(
        padding: const EdgeInsets.all(Sentin8Spacing.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.link, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: Sentin8Spacing.sm),
            Expanded(child: Text(providerName, style: Sentin8Text.bodyLarge)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Sentin8Spacing.sm, vertical: 2),
              decoration: BoxDecoration(color: isActive ? Sentin8Colors.success.withValues(alpha: 0.1) : Sentin8Colors.textSecondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(status, style: TextStyle(fontSize: 12, color: isActive ? Sentin8Colors.success : Sentin8Colors.textSecondary)),
            ),
          ]),
          if (scopes.isNotEmpty) ...[const SizedBox(height: Sentin8Spacing.sm), Wrap(spacing: 4, children: scopes.map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList())],
          const SizedBox(height: Sentin8Spacing.xs),
          Text('Created: $createdAt', style: Sentin8Text.labelSmall),
          if (expiresAt != null) Text('Expires: $expiresAt', style: Sentin8Text.labelSmall),
          if (isActive) ...[const SizedBox(height: Sentin8Spacing.sm), Row(children: [
            SizedBox(width: 100, child: OutlinedButton(onPressed: () => _consentsHook.refresh(consentId), child: const Text('Refresh', style: TextStyle(fontSize: 12)))),
            const SizedBox(width: Sentin8Spacing.sm),
            SizedBox(width: 100, child: OutlinedButton(onPressed: () => _revoke(consentId), style: OutlinedButton.styleFrom(foregroundColor: Sentin8Colors.error), child: const Text('Revoke', style: TextStyle(fontSize: 12)))),
          ])],
        ]),
      ),
    );
  }

  @override
  void dispose() { _consentsHook.dispose(); super.dispose(); }
}