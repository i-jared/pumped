import 'package:get_it/get_it.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_repo.dart';

final getIt = GetIt.instance;

void init() {
  getIt.registerSingleton<ShowsRepo>(ShowsRepo());
  getIt.registerSingleton<ShowsCubit>(ShowsCubit(getIt()),
      dispose: (s) => s.close());
  getIt.registerFactory<CreateShowCubit>(() => CreateShowCubit());
}
