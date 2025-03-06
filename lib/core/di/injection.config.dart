// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:uuid/uuid.dart' as _i706;

import '../../features/connection/data/datasources/mqtt_client.dart' as _i12;
import '../../features/connection/presentation/bloc/connection_bloc.dart'
    as _i904;
import '../../features/device/data/datasources/device_local_data_source.dart'
    as _i920;
import '../../features/device/data/datasources/device_remote_data_source.dart'
    as _i640;
import '../../features/device/data/repositories/device_repository_impl.dart'
    as _i740;
import '../../features/device/domain/repositories/device_repository.dart'
    as _i985;
import '../../features/device/domain/usecases/add_device.dart' as _i217;
import '../../features/device/domain/usecases/check_device_connection.dart'
    as _i243;
import '../../features/device/domain/usecases/delete_device.dart' as _i461;
import '../../features/device/domain/usecases/get_devices.dart' as _i217;
import '../../features/device/domain/usecases/set_schedule.dart' as _i200;
import '../../features/device/domain/usecases/toggle_all_switches.dart'
    as _i624;
import '../../features/device/domain/usecases/toggle_device_switch.dart'
    as _i564;
import '../../features/device/domain/usecases/update_device.dart' as _i848;
import '../../features/device/presentation/bloc/device_bloc.dart' as _i1022;
import '../../features/settings/data/datasources/settings_local_data_source.dart'
    as _i599;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/get_app_settings.dart' as _i134;
import '../../features/settings/domain/usecases/get_mqtt_config.dart' as _i659;
import '../../features/settings/domain/usecases/get_server_config.dart'
    as _i220;
import '../../features/settings/domain/usecases/save_app_settings.dart'
    as _i924;
import '../../features/settings/domain/usecases/save_mqtt_config.dart' as _i629;
import '../../features/settings/domain/usecases/save_server_config.dart'
    as _i542;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../network/network_info.dart' as _i932;
import '../utils/logger.dart' as _i221;
import 'injection.dart' as _i464;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> init(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final registerModule = _$RegisterModule();
  await gh.factoryAsync<_i460.SharedPreferences>(
    () => registerModule.sharedPreferences,
    preResolve: true,
  );
  gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
  gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
  gh.lazySingleton<_i706.Uuid>(() => registerModule.uuid);
  gh.lazySingleton<_i221.AppLogger>(() => _i221.AppLogger());
  gh.lazySingleton<_i920.DeviceLocalDataSource>(() =>
      _i920.DeviceLocalDataSourceImpl(
          sharedPreferences: gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(connectivity: gh<_i895.Connectivity>()));
  gh.lazySingleton<_i599.SettingsLocalDataSource>(() =>
      _i599.SettingsLocalDataSourceImpl(
          sharedPreferences: gh<_i460.SharedPreferences>()));
  gh.lazySingleton<_i674.SettingsRepository>(() => _i955.SettingsRepositoryImpl(
      localDataSource: gh<_i599.SettingsLocalDataSource>()));
  gh.lazySingleton<_i640.DeviceRemoteDataSource>(
      () => _i640.DeviceRemoteDataSourceImpl(
            client: gh<_i519.Client>(),
            settingsRepository: gh<_i674.SettingsRepository>(),
          ));
  gh.lazySingleton<_i12.MqttClientWrapper>(() => _i12.MqttClientWrapperImpl(
        settingsRepository: gh<_i674.SettingsRepository>(),
        logger: gh<_i221.AppLogger>(),
      ));
  gh.lazySingleton<_i134.GetAppSettings>(
      () => _i134.GetAppSettings(gh<_i674.SettingsRepository>()));
  gh.lazySingleton<_i659.GetMqttConfig>(
      () => _i659.GetMqttConfig(gh<_i674.SettingsRepository>()));
  gh.lazySingleton<_i220.GetServerConfig>(
      () => _i220.GetServerConfig(gh<_i674.SettingsRepository>()));
  gh.lazySingleton<_i924.SaveAppSettings>(
      () => _i924.SaveAppSettings(gh<_i674.SettingsRepository>()));
  gh.lazySingleton<_i629.SaveMqttConfig>(
      () => _i629.SaveMqttConfig(gh<_i674.SettingsRepository>()));
  gh.lazySingleton<_i542.SaveServerConfig>(
      () => _i542.SaveServerConfig(gh<_i674.SettingsRepository>()));
  gh.factory<_i904.ConnectionBloc>(() => _i904.ConnectionBloc(
        connectivity: gh<_i895.Connectivity>(),
        mqttClient: gh<_i12.MqttClientWrapper>(),
      ));
  gh.lazySingleton<_i985.DeviceRepository>(() => _i740.DeviceRepositoryImpl(
        localDataSource: gh<_i920.DeviceLocalDataSource>(),
        remoteDataSource: gh<_i640.DeviceRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
        uuid: gh<_i706.Uuid>(),
      ));
  gh.factory<_i585.SettingsBloc>(() => _i585.SettingsBloc(
        getAppSettings: gh<_i134.GetAppSettings>(),
        saveAppSettings: gh<_i924.SaveAppSettings>(),
        getServerConfig: gh<_i220.GetServerConfig>(),
        saveServerConfig: gh<_i542.SaveServerConfig>(),
        getMqttConfig: gh<_i659.GetMqttConfig>(),
        saveMqttConfig: gh<_i629.SaveMqttConfig>(),
      ));
  gh.lazySingleton<_i217.AddDevice>(
      () => _i217.AddDevice(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i243.CheckDeviceConnection>(
      () => _i243.CheckDeviceConnection(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i461.DeleteDevice>(
      () => _i461.DeleteDevice(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i217.GetDevices>(
      () => _i217.GetDevices(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i200.SetSchedule>(
      () => _i200.SetSchedule(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i624.ToggleAllSwitches>(
      () => _i624.ToggleAllSwitches(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i564.ToggleDeviceSwitch>(
      () => _i564.ToggleDeviceSwitch(gh<_i985.DeviceRepository>()));
  gh.lazySingleton<_i848.UpdateDevice>(
      () => _i848.UpdateDevice(gh<_i985.DeviceRepository>()));
  gh.factory<_i1022.DeviceBloc>(() => _i1022.DeviceBloc(
        getDevices: gh<_i217.GetDevices>(),
        addDevice: gh<_i217.AddDevice>(),
        updateDevice: gh<_i848.UpdateDevice>(),
        deleteDevice: gh<_i461.DeleteDevice>(),
        toggleDeviceSwitch: gh<_i564.ToggleDeviceSwitch>(),
        toggleAllSwitches: gh<_i624.ToggleAllSwitches>(),
        setSchedule: gh<_i200.SetSchedule>(),
        checkDeviceConnection: gh<_i243.CheckDeviceConnection>(),
      ));
  return getIt;
}

class _$RegisterModule extends _i464.RegisterModule {}
