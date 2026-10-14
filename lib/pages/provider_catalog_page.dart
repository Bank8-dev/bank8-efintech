// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech provider catalog — browse available external FDX data providers.
// Provider catalog screen.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../fdx_hooks.dart';
import '../url_router.dart';
import 'provider_detail_page.dart';

class ProviderCatalogPage extends StatefulWidget {
  final EFintechContext appContext;
  const ProviderCatalogPage({super.key, required this.appContext});
  @override
  State<ProviderCatalogPage> createState() => _ProviderCatalogPageState();
}

class _ProviderCatalogPageState extends State<ProviderCatalogPage> {
  late FdxProvidersHook _providersHook;
  @override
  void initState() { super.initState(); _providersHook = FdxProvidersHook(widget.appContext.services!.fdx); _providersHook.fetch(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Providers', style: Sentin8Text.headlineLarge),
          const SizedBox(height: Sentin8Spacing.sm),
          const Text('Browse available external FDX data providers.', style: Sentin8Text.bodyMedium),
          const SizedBox(height: Sentin8Spacing.lg),
          ListenableBuilder(listenable: _providersHook, builder: (_, __) {
            if (_providersHook.state.isLoading) return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
            final providers = _providersHook.providers;
            if (providers.isEmpty) return const GlassPanel(child: Center(child: Text('No providers available.', style: Sentin8Text.bodyLarge)));
            return Expanded(child: ListView.builder(itemCount: providers.length, itemBuilder: (context, index) {
              final p = providers[index];
              return GestureDetector(onTap: () {
                final id = p['id'] as String? ?? p['name'] as String? ?? '';
                if (id.isNotEmpty) pushRoute('/providers/$id');
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderDetailPage(appContext: widget.appContext, provider: p)));
              }, child: _buildProviderCard(p));
            }));
          }),
        ]),
      ),
    );
  }

  Widget _buildProviderCard(Map<String, dynamic> p) {
    final name = p['name'] as String? ?? 'Provider';
    final status = p['status'] as String? ?? 'available';
    final clusters = (p['supportedDataClusters'] as List<dynamic>?)?.cast<String>() ?? [];
    final isActive = status == 'available';
    return Padding(
      padding: const EdgeInsets.only(bottom: Sentin8Spacing.sm),
      child: GlassPanel(
        padding: const EdgeInsets.all(Sentin8Spacing.md),
        child: Row(children: [
          Icon(Icons.business, color: isActive ? Theme.of(context).colorScheme.primary : Sentin8Colors.textSecondary),
          const SizedBox(width: Sentin8Spacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: Sentin8Text.bodyLarge),
            if (clusters.isNotEmpty) Text(clusters.join(', '), style: Sentin8Text.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Sentin8Spacing.sm, vertical: 2),
            decoration: BoxDecoration(color: isActive ? Sentin8Colors.success.withValues(alpha: 0.1) : Sentin8Colors.textSecondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(status, style: TextStyle(fontSize: 12, color: isActive ? Sentin8Colors.success : Sentin8Colors.textSecondary)),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() { _providersHook.dispose(); super.dispose(); }
}