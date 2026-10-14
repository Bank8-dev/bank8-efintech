// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech landing page — delegates to sentin8's LandingPage.
import 'package:flutter/material.dart';
import 'package:sentin8/sentin8.dart' as s8;
import '../app_context.dart';

/// Landing page shown when the user is not signed in.
/// Delegates to the shared [s8.LandingPage] from sentin8.
class LandingPage extends StatelessWidget {
  final EFintechContext appContext;

  const LandingPage({super.key, required this.appContext});

  @override
  Widget build(BuildContext context) {
    return s8.LandingPage(
      runtimeContext: appContext.runtimeContext,
      auth: appContext.auth,
      defaultIcon: Icons.connecting_airports,
      descriptionText: 'Connect your external bank accounts and view your '
          'financial data in one place.',
    );
  }
}