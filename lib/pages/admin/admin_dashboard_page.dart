// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech admin dashboard — instance status, env vars, OAuth client summary.
// Admin dashboard — instance status, env vars, DCR summary.
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../app_context.dart';

class AdminDashboardPage extends StatelessWidget {
  final EFintechContext appContext;
  const AdminDashboardPage({super.key, required this.appContext});

  @override
  Widget build(BuildContext context) {
    final ctx = appContext.runtimeContext;
    return Scaffold(
      backgroundColor: Sentin8Colors.background,
      body: Padding(
        padding: const EdgeInsets.all(Sentin8Spacing.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary), onPressed: () => Navigator.pop(context)), const SizedBox(width: Sentin8Spacing.sm), const Text('Admin', style: Sentin8Text.headlineLarge)]),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Instance Information', style: Sentin8Text.headlineMedium),
            const SizedBox(height: Sentin8Spacing.md),
            _row('Hostname', ctx.hostname), _row('Organization', ctx.organizationId), _row('Environment', ctx.environmentId),
            _row('Auth Domain', ctx.authDomain), _row('BFF Domain', ctx.bffDomain), _row('Status', ctx.status),
          ])),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Environment Variables', style: Sentin8Text.headlineMedium),
            const SizedBox(height: Sentin8Spacing.md),
            const Text('No environment variables configured.', style: Sentin8Text.labelSmall),
            const SizedBox(height: Sentin8Spacing.xs),
            const Text('Secret values are never displayed. Only the name and version are shown.', style: Sentin8Text.labelSmall),
          ])),
          const SizedBox(height: Sentin8Spacing.lg),
          GlassPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('OAuth Client (DCR)', style: Sentin8Text.headlineMedium),
            const SizedBox(height: Sentin8Spacing.md),
            const Text('DCR is mandatory for all eFintech instances. The OAuth client was registered during setup.', style: Sentin8Text.bodyMedium),
            const SizedBox(height: Sentin8Spacing.md),
            Row(children: [const SizedBox(width: 160, child: Text('Registration Status', style: Sentin8Text.labelSmall)), Icon(Icons.check_circle, color: Sentin8Colors.success, size: 16), const SizedBox(width: Sentin8Spacing.xs), const Text('Registered', style: Sentin8Text.bodyMedium)]),
          ])),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.only(bottom: Sentin8Spacing.xs), child: Row(children: [SizedBox(width: 160, child: Text(label, style: Sentin8Text.labelSmall)), Expanded(child: Text(value, style: Sentin8Text.bodyMedium))]));
}