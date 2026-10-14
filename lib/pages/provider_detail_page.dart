// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech provider detail — provider metadata + consent start.
// Consent-start contract: see DESIGN.md §2 (recipient consent lifecycle).
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../url_router.dart';
// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

class ProviderDetailPage extends StatefulWidget {
  final EFintechContext appContext;
  final Map<String, dynamic> provider;
  const ProviderDetailPage({super.key, required this.appContext, required this.provider});
  @override
  State<ProviderDetailPage> createState() => _ProviderDetailPageState();
}

class _ProviderDetailPageState extends State<ProviderDetailPage> {
  String _duration = 'PERSISTENT';
  final _scopes = ['bank8:fdx:accountbasic:read', 'bank8:fdx:accountdetailed:read', 'bank8:fdx:transactions:read'];
  bool _starting = false;

  Future<void> _startConsent() async {
    setState(() => _starting = true);
    // Consent start (browser-redirect contract, DESIGN.md §2):
    // POST /proxy/fdx/v1/recipient/consents/start through the BFF proxy
    // (session cookie + CSRF) — an XHR, NOT a browser redirect. The JSON
    // response carries `authorization_url`; the app itself then performs
    // the browser navigation with location.replace so the provider's
    // consent UI opens in this tab. There is no GET BFF consent route.
    final fdx = widget.appContext.services?.fdx;
    final user = widget.appContext.auth.user;
    if (fdx == null || user == null) {
      setState(() => _starting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Session not ready — please try again')));
      return;
    }
    final providerId = widget.provider['id']?.toString() ?? '';
    // app_redirect_uri (the eFintech app origin) rides inside the OAuth
    // `state` on the PAR → authorize → callback round-trip so FDX's
    // callback can send the customer back here afterwards.
    final appOrigin = web.window.location.origin;
    String? authorizationUrl;
    String? errorText;
    try {
      final response = await fdx.post('/v1/recipient/consents/start', body: {
        'customer_id': user.id,
        'provider_id': providerId,
        'scopes': _scopes,
        'app_redirect_uri': appOrigin,
      });
      if (response.isSuccess && response.data != null) {
        authorizationUrl =
            response.data!['authorization_url'] as String? ??
                response.data!['redirectUrl'] as String?;
      } else {
        errorText = 'Consent start failed (HTTP ${response.statusCode})';
      }
    } catch (e) {
      errorText = 'Consent start error: $e';
    }
    if (!mounted) return;
    setState(() => _starting = false);
    if (kIsWeb && authorizationUrl != null && authorizationUrl.isNotEmpty) {
      // Use location.replace for a clean redirect (no history entry).
      web.window.location.replace(authorizationUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorText ??
              authorizationUrl ??
              'Consent could not be started')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.provider;
    final name = p['name'] as String? ?? 'Provider';
    final desc = p['description'] as String? ?? '';
    final clusters = (p['supportedDataClusters'] as List<dynamic>?)?.cast<String>() ?? [];
    final versions = (p['supportedFdxVersions'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary), onPressed: () { navigateTo('/providers'); Navigator.pop(context); }),
            const SizedBox(width: Sentin8Spacing.sm),
            Expanded(child: Text(name, style: Sentin8Text.headlineLarge)),
          ]),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (desc.isNotEmpty) ...[Text(desc, style: Sentin8Text.bodyLarge), const SizedBox(height: Sentin8Spacing.md)],
              if (versions.isNotEmpty) Text('FDX Versions: ${versions.join(', ')}', style: Sentin8Text.labelSmall),
              if (clusters.isNotEmpty) ...[const SizedBox(height: Sentin8Spacing.sm), const Text('Data Clusters', style: Sentin8Text.labelSmall), Wrap(spacing: 4, children: clusters.map((c) => Chip(label: Text(c, style: const TextStyle(fontSize: 10)), padding: EdgeInsets.zero, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList())],
            ]),
          ),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Consent Duration', style: Sentin8Text.headlineMedium),
              const SizedBox(height: Sentin8Spacing.sm),
              SegmentedButton<String>(
                segments: const [ButtonSegment(value: 'ONE_TIME', label: Text('One Time')), ButtonSegment(value: 'PERSISTENT', label: Text('Persistent')), ButtonSegment(value: 'TIME_BOUND', label: Text('Time Bound'))],
                selected: {_duration},
                onSelectionChanged: (s) => setState(() => _duration = s.first),
              ),
              const SizedBox(height: Sentin8Spacing.md),
              const Text('Scopes', style: Sentin8Text.headlineMedium),
              const SizedBox(height: Sentin8Spacing.sm),
              ..._scopes.map((s) => CheckboxListTile(title: Text(s, style: Sentin8Text.bodyMedium), value: true, onChanged: null, dense: true)),
            ]),
          ),
          const SizedBox(height: Sentin8Spacing.lg),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _starting ? null : _startConsent,
            child: _starting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Connect & Authorize'),
          )),
        ]),
      ),
    );
  }
}