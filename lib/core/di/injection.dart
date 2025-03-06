import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:ace_smarthome/core/di/injection.config.dart';

final getIt = GetIt.instance;

// สร้าง module สำหรับ third-party dependencies
@module
abstract class RegisterModule {
  @preResolve // สำหรับ async dependencies
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  http.Client get httpClient => http.Client();

  @lazySingleton
  Uuid get uuid => const Uuid();
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  await init(getIt);
}
