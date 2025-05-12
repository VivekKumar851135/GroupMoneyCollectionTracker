import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_collection_2/Screen/ErrorScreen.dart';
import 'package:money_collection_2/Screen/HomeScreen.dart';
import 'package:money_collection_2/Screen/JoinScreen.dart';
import 'package:money_collection_2/Screen/LoginScreen.dart';
import 'package:money_collection_2/Screen/RegisterScreen.dart';
import 'package:money_collection_2/Screen/UserProfileScreen.dart';
import 'package:money_collection_2/Utility/FetchApi.dart';
import 'package:provider/provider.dart';

// Firebase message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    debugPrint('Handling a background message: ${message.messageId}');
    
    if (message.data.isNotEmpty && message.data['groupId'] != null) {
      final String? groupId = message.data['groupId'];
      if (groupId != null) {
        final navigatorKey = GlobalKey<NavigatorState>();
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => Homescreen(groupId: int.parse(groupId)),
        ));
      }
    }
  } catch (e) {
    debugPrint('Error handling background message: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(); // Request permission for iOS

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(ChangeNotifierProvider(
      create: (context) => FetchApiModel(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<void> _initFuture;

  // Define the navigator key here to avoid initialization issues
  late final GlobalKey<NavigatorState> navigatorKey;

  // Add this field at the top of your _MyAppState class
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Remove the late _router declaration and replace with a getter
  GoRouter get _router => GoRouter(
    initialLocation: '/',
    navigatorKey: navigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => Homescreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterPage(),
      ),
      GoRoute(
        path: '/error',
        builder: (context, state) {
          final errorMessage = state.uri.queryParameters['errorMsg'];
          return Errorscreen(errorMessage: errorMessage);
        },
      ),
      GoRoute(
        path: '/join',
        builder: (context, state) {
          final adminId = state.uri.queryParameters['adminId'];
          final groupId = state.uri.queryParameters['groupId'];
          String decodedGroupId = utf8.decode(base64Url.decode(groupId!));
          String decodedAdminId = utf8.decode(base64Url.decode(adminId!));
          return JoinScreen(
            adminId: decodedAdminId,
            groupId: decodedGroupId,
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          return UserProfileScreen();
        },
      ),
    ],
    redirect: (context, state) {
      final uri = state.fullPath;
      final fetchApiModel = Provider.of<FetchApiModel>(context, listen: false);

      debugPrint("isInitialized: ${fetchApiModel.isInitialized}");
      debugPrint("isAuthenticated: ${fetchApiModel.isAuthenticated}");

      if (fetchApiModel.isInitialized && uri!.startsWith('/join')) {
        final String? adminId = state.uri.queryParameters['adminId'];
        final String? groupId = state.uri.queryParameters['groupId'];

        String decodedGroupId = utf8.decode(base64Url.decode(groupId!));
        String decodedAdminId = utf8.decode(base64Url.decode(adminId!));

        debugPrint("Decoded groupId: $decodedGroupId");
        debugPrint("Decoded adminId: $decodedAdminId");

        if (fetchApiModel.isAuthenticated) {
          return null; // Let the user go to the /join page
        } else if (adminId != null || groupId != null) {
          return '/login?groupId=$groupId&adminId=$adminId';
        }
      }

      if (!fetchApiModel.isAuthenticated && uri == '/') {
        return '/login';
      } else if (!fetchApiModel.isInitialized && uri == '/') return '/login';
      return null; // No redirection needed
    },
  );

  @override
  void initState() {
    super.initState();
    navigatorKey = GlobalKey<NavigatorState>(); // Initialize navigatorKey here

    _initFuture = Provider.of<FetchApiModel>(context, listen: false).verifyJwtToken();

    // Initialize Firebase Messaging
    _setupFirebaseMessaging();
  }

  // Set up Firebase messaging for foreground and background
  void _setupFirebaseMessaging() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received a foreground message: ${message.notification}');
      
      if (message.notification != null && mounted) {
        _showNotification(message.notification!.body ?? 'Notification received');
      }
    });

    // Notification click handling
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification clicked: ${message.messageId}');
      if (mounted) {
        Provider.of<FetchApiModel>(context, listen: false).setIsNavigated(false);
        _handleNotificationClick(message);
      }
    });

    // Get the device token with error handling
 try {
  await FirebaseMessaging.instance.deleteToken();
    String? token = await messaging.getToken();
    debugPrint("Firebase Token: $token");

    if (token == null) {
      debugPrint("Failed to get FCM token. Token is null.");
    }
  } catch (e) {
    debugPrint("Error getting FCM token: $e");
  }
  }

  // Update the notification method with proper delay and error handling
  void _showNotification(String message) {
    if (!mounted) return;
    
    // Add a slight delay to ensure the Scaffold is ready
    Future.delayed(Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      try {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        debugPrint('Error showing notification: $e');
      }
    });
  }

  // Handle notification click
  void _handleNotificationClick(RemoteMessage message) {
    // Extract the groupId from the message data
    final String? groupId = message.data['groupId'];
    final String? userId=message.data['userId'];

    if (groupId != null) {
      // Navigate to the GroupScreen with the extracted groupId using the navigatorKey
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => Homescreen(groupId: int.parse(groupId), userId: int.parse(userId!)),
        ));
      }
    } else {
      // Handle cases where the groupId is missing (optional)
      _showNotification('Notification clicked, but no valid groupId found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      builder: (context, child) {
        // Wrap everything in a Scaffold to ensure there's always one available
        return Scaffold(
          body: FutureBuilder(
            future: _initFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              return child ?? const SizedBox.shrink();
            },
          ),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}