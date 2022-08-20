import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_pdg/helper/notification_helper.dart';
import 'package:flutter_pdg/helper/responsive_helper.dart';
import 'package:flutter_pdg/helper/router_helper.dart';
import 'package:flutter_pdg/localization/app_localization.dart';
import 'package:flutter_pdg/provider/auth_provider.dart';
import 'package:flutter_pdg/provider/banner_provider.dart';
import 'package:flutter_pdg/provider/cart_provider.dart';
import 'package:flutter_pdg/provider/category_provider.dart';
import 'package:flutter_pdg/provider/chat_provider.dart';
import 'package:flutter_pdg/provider/coupon_provider.dart';
import 'package:flutter_pdg/provider/localization_provider.dart';
import 'package:flutter_pdg/provider/news_letter_controller.dart';
import 'package:flutter_pdg/provider/notification_provider.dart';
import 'package:flutter_pdg/provider/order_provider.dart';
import 'package:flutter_pdg/provider/location_provider.dart';
import 'package:flutter_pdg/provider/product_provider.dart';
import 'package:flutter_pdg/provider/language_provider.dart';
import 'package:flutter_pdg/provider/onboarding_provider.dart';
import 'package:flutter_pdg/provider/profile_provider.dart';
import 'package:flutter_pdg/provider/search_provider.dart';
import 'package:flutter_pdg/provider/set_menu_provider.dart';
import 'package:flutter_pdg/provider/splash_provider.dart';
import 'package:flutter_pdg/provider/theme_provider.dart';
import 'package:flutter_pdg/provider/wishlist_provider.dart';
import 'package:flutter_pdg/theme/dark_theme.dart';
import 'package:flutter_pdg/theme/light_theme.dart';
import 'package:flutter_pdg/utill/app_constants.dart';
import 'package:flutter_pdg/utill/routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'di_container.dart' as di;
import 'provider/time_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

AndroidNotificationChannel channel;

Future<void> main() async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = new MyHttpOverrides();
  }
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  if (GetPlatform.isWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
      apiKey: "AIzaSyALdpb2H-fsQrLq3JrJt61jp3cG7vtnYaU",
      appId: "0:596098361190:web:e37db47ed624672f3c0aa7",
      messagingSenderId: "596098361189",
      projectId: "srwong-app",
    ));
  } else {
    await Firebase.initializeApp();
  }
  await di.init();
  int _orderID;
  try {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
      );
      final RemoteMessage remoteMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (remoteMessage != null) {
        _orderID = remoteMessage.notification.titleLocKey != null
            ? int.parse(remoteMessage.notification.titleLocKey)
            : null;
      }
      // await MyNotification.initialize(flutterLocalNotificationsPlugin);
      await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
      FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  } catch (e) {}
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => di.sl<ThemeProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<SplashProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LanguageProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<OnBoardingProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CategoryProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<BannerProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProductProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<LocalizationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<AuthProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<LocationProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<LocalizationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CartProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<OrderProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ChatProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<SetMenuProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<ProfileProvider>()),
      ChangeNotifierProvider(
          create: (context) => di.sl<NotificationProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<CouponProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<WishListProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<SearchProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<NewsLetterProvider>()),
      ChangeNotifierProvider(create: (context) => di.sl<TimerProvider>()),
    ],
    child: MyApp(orderId: _orderID, isWeb: !kIsWeb),
  ));
}

class MyApp extends StatefulWidget {
  final int orderId;
  final bool isWeb;
  MyApp({@required this.orderId, @required this.isWeb});

  static final navigatorKey = new GlobalKey<NavigatorState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    RouterHelper.setupRouter();

    if (kIsWeb) {
      Provider.of<SplashProvider>(context, listen: false).initSharedData();
      Provider.of<CartProvider>(context, listen: false).getCartData();
      _route();
    }
  }

  void _route() {
    Provider.of<SplashProvider>(context, listen: false)
        .initConfig(context)
        .then((bool isSuccess) {
      if (isSuccess) {
        Timer(Duration(seconds: ResponsiveHelper.isMobilePhone() ? 1 : 0),
            () async {
          if (Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
            Provider.of<AuthProvider>(context, listen: false).updateToken();
            await Provider.of<WishListProvider>(context, listen: false)
                .initWishList(
              context,
              Provider.of<LocalizationProvider>(context, listen: false)
                  .locale
                  .languageCode,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Locale> _locals = [];
    AppConstants.languages.forEach((language) {
      _locals.add(Locale(language.languageCode, language.countryCode));
    });

    return Consumer<SplashProvider>(
      builder: (context, splashProvider, child) {
        return (kIsWeb && splashProvider.configModel == null)
            ? SizedBox()
            : MaterialApp(
                initialRoute: ResponsiveHelper.isMobilePhone()
                    ? widget.orderId == null
                        ? Routes.getSplashRoute()
                        : Routes.getOrderDetailsRoute(widget.orderId)
                    : splashProvider.configModel.maintenanceMode
                        ? Routes.getMaintainRoute()
                        : Routes.getMainRoute(),
                onGenerateRoute: RouterHelper.router.generator,
                title: splashProvider.configModel != null
                    ? splashProvider.configModel.restaurantName ?? ''
                    : AppConstants.APP_NAME,
                debugShowCheckedModeBanner: false,
                navigatorKey: MyApp.navigatorKey,
                theme: Provider.of<ThemeProvider>(context).darkTheme
                    ? dark
                    : light,
                locale: Provider.of<LocalizationProvider>(context).locale,
                localizationsDelegates: [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: _locals,
                scrollBehavior: MaterialScrollBehavior().copyWith(dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown
                }),
              );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
