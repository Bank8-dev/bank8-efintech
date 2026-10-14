// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Bank8:EFintech
// SPDX-License-Identifier: Apache-2.0

// eFintech app context — central runtime state.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'bootstrap.dart';
import 'auth_provider.dart';
import 'services.dart';

class EFintechContext extends ChangeNotifier {
  final AppRuntimeContext runtimeContext;
  final AuthProvider auth;
  EFintechServices? services;
  final String correlationId;

  EFintechContext._({required this.runtimeContext, required this.auth, required this.correlationId}) {
    auth.addListener(_onAuthChanged);
    _updateServices();
  }

  static Future<EFintechContext> create(AppRuntimeContext runtimeContext) async {
    final corrId = generateCorrelationId();
    final auth = AuthProvider(bffBaseUrl: runtimeContext.bffBaseUrl, authDomain: runtimeContext.authDomain);
    auth.onRedirect = (String url) { web.window.location.href = url; };
    await auth.init();
    return EFintechContext._(runtimeContext: runtimeContext, auth: auth, correlationId: corrId);
  }

  void _onAuthChanged() { _updateServices(); notifyListeners(); }
  void _updateServices() {
    services = EFintechServices(bffBaseUrl: runtimeContext.bffBaseUrl, csrfToken: auth.csrfToken, correlationId: correlationId);
  }

  bool isFeatureEnabled(String feature) => runtimeContext.featureFlags[feature] ?? true;

  @override
  void dispose() { auth.removeListener(_onAuthChanged); auth.dispose(); super.dispose(); }
}
class EFintechContextProvider extends StatefulWidget {
  final AppRuntimeContext runtimeContext;
  final Widget child;
  const EFintechContextProvider({super.key, required this.runtimeContext, required this.child});
  @override
  State<EFintechContextProvider> createState() => _EFintechContextProviderState();
  static EFintechContext? of(BuildContext context) {
    final inh = context.dependOnInheritedWidgetOfExactType<_EFintechContextInherited>();
    return inh?.eFintechContext;
  }
}

class _EFintechContextProviderState extends State<EFintechContextProvider> {
  EFintechContext? _context;
  @override
  void initState() { super.initState(); _initContext(); }
  Future<void> _initContext() async {
    final ctx = await EFintechContext.create(widget.runtimeContext);
    if (mounted) setState(() => _context = ctx);
  }
  @override
  void dispose() { _context?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (_context == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _EFintechContextInherited(eFintechContext: _context!, child: widget.child);
  }
}

class _EFintechContextInherited extends InheritedWidget {
  final EFintechContext eFintechContext;
  final Widget child;
  const _EFintechContextInherited({required this.eFintechContext, required this.child}) : super(child: child);
  @override
  bool updateShouldNotify(_EFintechContextInherited old) => eFintechContext != old.eFintechContext;
}