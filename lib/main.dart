import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/member.dart';
import 'models/fund.dart';
import 'models/transaction.dart';
import 'models/loan.dart';
import 'models/contribution.dart';
import 'models/penalty.dart';
import 'models/loan_settings.dart';
import 'services/database_service.dart';
import 'providers/app_state_provider.dart';
import 'providers/language_provider.dart';
import 'providers/contribution_settings_provider.dart';
import 'providers/loan_settings_provider.dart';
import 'screens/dashboard_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(MemberAdapter());
  Hive.registerAdapter(FundAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(LoanAdapter());
  Hive.registerAdapter(ContributionAdapter());
  Hive.registerAdapter(FundContributionAdapter());
  Hive.registerAdapter(MemberStatusAdapter());
  Hive.registerAdapter(FundTypeAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(LoanStatusAdapter());
  Hive.registerAdapter(PenaltyAdapter());
  Hive.registerAdapter(PenaltyRuleAdapter());
  Hive.registerAdapter(PenaltyTypeAdapter());
  Hive.registerAdapter(PenaltyStatusAdapter());
  Hive.registerAdapter(PenaltyCalculationTypeAdapter());
  Hive.registerAdapter(LoanSettingsAdapter());

  // Initialize database service
  await DatabaseService.instance.init();

  runApp(const FinancialManagementApp());
}

class FinancialManagementApp extends StatelessWidget {
  const FinancialManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ContributionSettingsProvider()),
        ChangeNotifierProvider(create: (_) => LoanSettingsProvider()),
      ],
      child: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LanguageProvider>().initialize();
      context.read<AppStateProvider>().initialize();
      context.read<ContributionSettingsProvider>().initialize();
      context.read<LoanSettingsProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'asso_njangui',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English
            Locale('fr', ''), // French
          ],
          locale: languageProvider.currentLocale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
            cardTheme: const CardThemeData(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          home: const DashboardScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
