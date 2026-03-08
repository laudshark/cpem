import 'package:flutter/material.dart';

import '../core/repositories/finance_repository.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import '../features/contracts/contracts_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/ledger/ledger_page.dart';
import '../features/reports/reports_page.dart';

class CpemApp extends StatefulWidget {
  const CpemApp({required this.repository, super.key});

  final FinanceRepository repository;

  @override
  State<CpemApp> createState() => _CpemAppState();
}

class _CpemAppState extends State<CpemApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(repository: widget.repository)..load();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CPEM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: AppShell(appState: _appState),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({required this.appState, super.key});

  final AppState appState;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final pages = <Widget>[
          DashboardPage(appState: widget.appState),
          ContractsPage(appState: widget.appState),
          LedgerPage(appState: widget.appState),
          ReportsPage(appState: widget.appState),
        ];

        return Scaffold(
          body: SafeArea(child: pages[_currentIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Contracts',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Ledger',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: 'Reports',
              ),
            ],
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        );
      },
    );
  }
}
