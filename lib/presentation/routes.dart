import 'package:auto_route/auto_route_annotations.dart';
import 'package:fusecash/presentation/route_guards.dart';
import 'package:fusecash/presentation/screens/home_screen.dart';
import 'package:fusecash/presentation/screens/security_screen.dart';
import 'package:fusecash/presentation/onboard/screens/restore_wallet_screen.dart';
import 'package:fusecash/presentation/onboard/screens/username_screen.dart';
import 'package:fusecash/presentation/onboard/screens/signup_screen.dart';
import 'package:fusecash/presentation/onboard/screens/verify_screen.dart';
import 'package:fusecash/presentation/onboard/screens/splash_screen.dart';
import 'package:fusecash/presentation/screens/colored_pincode_screen.dart';
import 'package:fusecash/presentation/screens/lock_screen.dart';
import 'package:fusecash/presentation/screens/send_amount.dart';
import 'package:fusecash/presentation/screens/send_review.dart';
import 'package:fusecash/presentation/screens/send_success.dart';
import 'package:fusecash/presentation/screens/unknown_route.dart';
import 'package:fusecash/presentation/screens/webview_screen.dart';

@MaterialAutoRouter(
  generateNavigationHelperExtension: true,
  routes: [
    MaterialRoute(page: LockScreen, name: 'lockScreen', initial: true),
    MaterialRoute(page: SecurityScreen, name: 'securityScreen'),
    MaterialRoute(page: ColoredPincodeScreen, name: 'pincode'),
    MaterialRoute(page: RecoveryPage),
    MaterialRoute(page: SplashScreen),
    MaterialRoute(page: SignupScreen),
    MaterialRoute(page: VerifyScreen),
    MaterialRoute(page: UserNameScreen),
    MaterialRoute(page: WebViewScreen, name: 'webview', fullscreenDialog: true),
    MaterialRoute(
        guards: [AuthGuard], page: MainHomeScreen, name: 'homeScreen'),
    MaterialRoute(guards: [AuthGuard], page: SendAmountScreen),
    MaterialRoute(guards: [AuthGuard], page: SendReviewScreen),
    MaterialRoute(guards: [AuthGuard], page: SendSuccessScreen),
    AdaptiveRoute(path: '*', page: UnknownRouteScreen)
  ],
)
class $Router {}
