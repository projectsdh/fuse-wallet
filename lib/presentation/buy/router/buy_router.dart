import 'package:auto_route/auto_route_annotations.dart';
import 'package:fusecash/presentation/buy/screens/business.dart';
import 'package:fusecash/presentation/buy/screens/buy.dart';
import 'package:fusecash/presentation/buy/screens/map.dart';

@MaterialAutoRouter(
  generateNavigationHelperExtension: true,
  routesClassName: "BusinessesRoutes",
  routes: <AutoRoute>[
    MaterialRoute(initial: true, page: BuyScreen),
    MaterialRoute(page: BusinessPage),
    MaterialRoute(page: MapScreen),
  ],
)
class $BuyRouter {}
