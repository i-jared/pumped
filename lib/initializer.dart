import 'package:get_it/get_it.dart';
import 'package:pumped/services/http_client.dart';
import 'package:pumped/state/auth/auth_cubit.dart';
import 'package:pumped/state/auth/auth_repo.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_repo.dart';

final getIt = GetIt.instance;

void init() {
  // Services
  getIt.registerSingleton<Api>(Api.instance);
  // Repos
  getIt.registerSingleton<ShowsRepo>(ShowsRepo());
  getIt.registerSingleton<AuthRepo>(AuthRepo());
  // Cubits
  getIt.registerSingleton<ShowsCubit>(ShowsCubit(getIt()),
      dispose: (s) => s.close());
  getIt.registerSingleton<AuthCubit>(AuthCubit(getIt()),
      dispose: (s) => s.close());
  getIt.registerFactory<CreateShowCubit>(() => CreateShowCubit());
}
