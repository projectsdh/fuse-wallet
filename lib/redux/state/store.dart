import 'package:fusecash/constants/env.dart';
import 'package:fusecash/models/app_state.dart';
import 'package:fusecash/redux/reducers/app_reducer.dart';
import 'package:fusecash/redux/state/secure_storage.dart';
import 'package:fusecash/utils/log/log.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';

class AppFactory {
  static AppFactory _singleton;
  Store<AppState> _store;

  AppFactory._();

  factory AppFactory() {
    if (_singleton == null) {
      _singleton = AppFactory._();
    }
    return _singleton;
  }

  Future<Store<AppState>> getStore() async {
    if (_store == null) {
      final persistor = Persistor<AppState>(
          storage: secureStorage,
          serializer: JsonSerializer<AppState>(AppState.fromJson),
          debug: Env.IS_DEBUG);

      AppState initialState;
      try {
        initialState = await persistor.load();
      } catch (e) {
        log.error('ERROR - getStore $e');
        initialState = AppState.initial();
      }

      final List<Middleware<AppState>> wms = [
        thunkMiddleware,
        persistor.createMiddleware(),
      ];

      if (Env.IS_DEBUG) {
        wms.add(LoggingMiddleware.printer());
      }

      _store = Store<AppState>(
        appReducer,
        initialState: initialState,
        middleware: wms,
      );
    }

    return _store;
  }
}
