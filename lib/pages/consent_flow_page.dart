// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech consent flow page — consent start and status polling.
// Consent flow — consent status polling.
import 'package:flutter/material.dart';
import '../theme.dart';
import '../app_context.dart';
import '../fdx_hooks.dart';

class ConsentFlowPage extends StatefulWidget {
  final EFintechContext appContext;
  final String? dataProviderId;
  const ConsentFlowPage({super.key, required this.appContext, this.dataProviderId});
  @override
  State<ConsentFlowPage> createState() => _ConsentFlowPageState();
}

class _ConsentFlowPageState extends State<ConsentFlowPage> {
  late FdxConsentsHook _consentsHook;
  String? _status;
  @override
  void initState() { super.initState(); _consentsHook = FdxConsentsHook(widget.appContext.services!.fdx); _consentsHook.fetch(); _pollStatus(); }

  Future<void> _pollStatus() async {
    // Poll consent status until active or failed
    for (var i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      await _consentsHook.fetch();
      if (mounted) setState(() {});
      final latest = _consentsHook.consents.isNotEmpty ? _consentsHook.consents.first : null;
      if (latest != null) {
        final status = latest['status'] as String?;
        if (status == 'ACTIVE' || status == 'FAILED') { setState(() => _status = status); return; }
      }
    }
    if (mounted) setState(() => _status = 'TIMEOUT');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Consent Flow', style: Sentin8Text.headlineLarge),
          SizedBox(height: Sentin8Spacing.lg),
          if (_status == null) ...[
            GlassPanel(child: Column(children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              SizedBox(height: Sentin8Spacing.md),
              Text('Waiting for authorization...', style: Sentin8Text.headlineMedium),
              SizedBox(height: Sentin8Spacing.xs),
              Text('Complete the authorization on the external provider page.', style: Sentin8Text.bodyMedium, textAlign: TextAlign.center),
            ])),
          ] else if (_status == 'ACTIVE') ...[
            const GlassPanel(child: Column(children: [
              Icon(Icons.check_circle, size: 48, color: Sentin8Colors.success),
              SizedBox(height: Sentin8Spacing.md),
              Text('Consent Active!', style: Sentin8Text.headlineMedium),
            ])),
          ] else if (_status == 'FAILED') ...[
            const GlassPanel(child: Column(children: [
              Icon(Icons.error, size: 48, color: Sentin8Colors.error),
              SizedBox(height: Sentin8Spacing.md),
              Text('Authorization Failed', style: Sentin8Text.headlineMedium),
            ])),
          ] else ...[
            const GlassPanel(child: Column(children: [
              Icon(Icons.timer_off, size: 48, color: Sentin8Colors.warning),
              SizedBox(height: Sentin8Spacing.md),
              Text('Authorization Timed Out', style: Sentin8Text.headlineMedium),
            ])),
          ],
        ]),
      ),
    );
  }

  @override
  void dispose() { _consentsHook.dispose(); super.dispose(); }
}