import 'package:ace_smarthome/features/device/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ace_smarthome/core/di/injection.dart';
import 'package:ace_smarthome/core/theme/app_theme.dart';
import 'package:ace_smarthome/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';
import 'package:ace_smarthome/features/connection/presentation/bloc/connection_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // กำหนดให้แอปรันได้ทั้งแนวตั้งและแนวนอน
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Setup dependency injection - รอจนกว่าจะเสร็จ
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider(
          create: (context) => getIt<DeviceBloc>()..add(LoadDevices()),
        ),
        BlocProvider(
          create: (context) => getIt<ConnectionBloc>()..add(InitConnection()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'AceCom SmartHome',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const DashboardPage(),
          );
        },
      ),
    );
  }
}
