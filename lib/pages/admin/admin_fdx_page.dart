// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech admin FDX page — provider catalog management, consent overview, retrieval job monitoring.
// Admin FDX — provider catalog, consent overview, retrieval monitoring.
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../app_context.dart';
import '../../fdx_hooks.dart';

class AdminFdxPage extends StatefulWidget {
  final EFintechContext appContext;
  const AdminFdxPage({super.key, required this.appContext});
  @override
  State<AdminFdxPage> createState() => _AdminFdxPageState();
}

class _AdminFdxPageState extends State<AdminFdxPage> {
  late FdxProvidersHook _providersHook;
  late FdxConsentsHook _consentsHook;
  @override
  void initState() { super.initState(); _providersHook = FdxProvidersHook(widget.appContext.services!.fdx); _consentsHook = FdxConsentsHook(widget.appContext.services!.fdx); _providersHook.fetch(); _consentsHook.fetch(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary), onPressed: () => Navigator.pop(context)), const SizedBox(width: Sentin8Spacing.sm), const Text('FDX Recipient Admin', style: Sentin8Text.headlineLarge)]),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _providersHook, builder: (_, __) {
            final providers = _providersHook.providers;
            return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Provider Catalog', style: Sentin8Text.headlineMedium),
              const SizedBox(height: Sentin8Spacing.md),
              if (providers.isEmpty) const Text('No providers configured.', style: Sentin8Text.bodyMedium)
              else ...providers.map((p) => ListTile(dense: true, leading: Icon(Icons.business, color: Theme.of(context).colorScheme.primary), title: Text(p['name'] as String? ?? 'Provider', style: Sentin8Text.bodyMedium), subtitle: Text(p['status'] as String? ?? 'available', style: Sentin8Text.labelSmall))),
            ]));
          }),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _consentsHook, builder: (_, __) {
            final consents = _consentsHook.consents;
            final active = consents.where((c) => c['status'] == 'ACTIVE').length;
            final revoked = consents.where((c) => c['status'] == 'REVOKED').length;
            return GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Consent Overview', style: Sentin8Text.headlineMedium),
              const SizedBox(height: Sentin8Spacing.md),
              Row(children: [
                Expanded(child: _stat('Active', '$active', Sentin8Colors.success)),
                const SizedBox(width: Sentin8Spacing.sm),
                Expanded(child: _stat('Revoked', '$revoked', Sentin8Colors.error)),
                const SizedBox(width: Sentin8Spacing.sm),
                Expanded(child: _stat('Total', '${consents.length}', Theme.of(context).colorScheme.primary)),
              ]),
            ]));
          }),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(Sentin8Spacing.md),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), Text(label, style: Sentin8Text.labelSmall, textAlign: TextAlign.center)]),
    );
  }

  @override
  void dispose() { _providersHook.dispose(); _consentsHook.dispose(); super.dispose(); }
}