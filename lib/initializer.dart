import 'package:get_it/get_it.dart';
import 'package:pumped/services/http_client.dart';
import 'package:pumped/services/music_player.dart';
import 'package:pumped/services/my_router.dart';
import 'package:pumped/services/notify_service.dart';
import 'package:pumped/state/music/music_cubit.dart';
import 'package:pumped/state/music/music_repo.dart';
import 'package:pumped/state/create_show/create_show_cubit.dart';
import 'package:pumped/state/notify/notify_cubit.dart';
import 'package:pumped/state/notify/notify_repo.dart';
import 'package:pumped/state/shows/shows_cubit.dart';
import 'package:pumped/state/shows/shows_repo.dart';

final getIt = GetIt.instance;

void init() {
  // Services
  getIt.registerSingleton<Api>(Api.instance);
  getIt.registerSingleton<MyRouter>(MyRouter());
  getIt.registerSingleton<MusicPlayer>(MusicPlayer());
  getIt.registerSingleton<NotifyService>(NotifyService());
  // Repos
  getIt.registerSingleton<ShowsRepo>(ShowsRepo());
  getIt.registerSingleton<MusicRepo>(MusicRepo());
  getIt.registerSingleton<NotifyRepo>(NotifyRepo(getIt()));
  // Cubits
  getIt.registerSingleton<ShowsCubit>(ShowsCubit(getIt()),
      dispose: (s) => s.close());
  getIt.registerSingleton<MusicAuthCubit>(MusicAuthCubit(getIt()),
      dispose: (s) => s.close());
  getIt.registerSingleton<NotifyCubit>(NotifyCubit(getIt()),
      dispose: (s) => s.close());
  getIt.registerFactory<CreateShowCubit>(() => CreateShowCubit());
}
