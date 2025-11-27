import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/worker/worker_dashboard_bloc.dart';
import 'repository/worker_dashboard_repository.dart';
import 'services/worker_service.dart';
import 'pages/auth/login_page.dart';
import 'pages/main_screen.dart';
import 'pages/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
          create:
              (_) => WorkerDashboardBloc(
                repository: WorkerDashboardRepository(
                  workerService: WorkerService(),
                ),
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pointage App',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: const Color(0xFFFF5C02),
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (context) => const PointageLoginPage(),
          '/main': (context) => const MainScreen(),
        },
        onGenerateRoute: (settings) {
          // Gérer les routes avec des arguments si nécessaire
          return null;
        },
      ),
    );
  }
}
