// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// Uncomment and update the notification service
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationService._internal();

  factory NotificationService() => _instance;

  /// Checks if notifications are enabled
  Future<bool> get isNotificationsEnabled async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Requests notification permissions if not already granted
  Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint(
        'Notification permission status: ${settings.authorizationStatus}',
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (error) {
      debugPrint('Error requesting notification permissions: $error');
      return false;
    }
  }

  // Rest of the existing notification service code...
  // [Previous implementation continues...]
}
// /// A service class that handles all notification-related functionality
// /// including token management and notification callbacks.
// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   // Private constructor
//   NotificationService._internal();

//   /// Factory constructor to return the same instance (singleton pattern)
//   factory NotificationService() => _instance;

//   /// Initializes the notification service with necessary permissions and callbacks
//   Future<void> initialize() async {
//     try {
//       await _requestNotificationPermissions();
//       await _setupTokenRefreshHandler();
//       _setupNotificationListeners();
//       debugPrint('Notification service initialized successfully');
//     } catch (error, stackTrace) {
//       debugPrint('Failed to initialize notification service: $error');
//       debugPrint('Stack trace: $stackTrace');
//       rethrow;
//     }
//   }

//   /// Requests notification permissions from the user
//   Future<void> _requestNotificationPermissions() async {
//     try {
//       final settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );

//       debugPrint(
//         'Notification permission status: ${settings.authorizationStatus}',
//       );
//     } catch (error) {
//       debugPrint('Error requesting notification permissions: $error');
//       rethrow;
//     }
//   }

//   /// Sets up the FCM token refresh handler
//   Future<void> _setupTokenRefreshHandler() async {
//     try {
//       final token = await _firebaseMessaging.getToken();
//       _handleNewToken(token);

//       // Listen for token refresh
//       _firebaseMessaging.onTokenRefresh.listen(_handleNewToken);
//     } catch (error) {
//       debugPrint('Error setting up token refresh handler: $error');
//       rethrow;
//     }
//   }

//   /// Handles a new FCM token
//   void _handleNewToken(String? token) {
//     if (token == null) {
//       debugPrint('Failed to get FCM token');
//       return;
//     }

//     debugPrint('FCM Token: $token');
//     // TODO: Send token to your server
//     // await _apiService.updateFcmToken(token);
//   }

//   /// Sets up notification listeners for different notification states
//   void _setupNotificationListeners() {
//     // Handle foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _handleForegroundNotification(message);
//     });

//     // Handle when app is opened from a terminated state
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleNotificationOpened(message);
//       }
//     });

//     // Handle when app is in background and opened via notification
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       _handleNotificationOpened(message);
//     });
//   }

//   /// Handles notifications received while the app is in the foreground
//   void _handleForegroundNotification(RemoteMessage message) {
//     debugPrint('Notification received in foreground:');
//     _logNotificationDetails(message);

//     // TODO: Show a local notification or update UI
//     // _showLocalNotification(message);
//   }

//   /// Handles when a notification is tapped/opened
//   void _handleNotificationOpened(RemoteMessage message) {
//     debugPrint('App opened from notification:');
//     _logNotificationDetails(message);

//     // TODO: Navigate to specific screen based on notification data
//     // _navigateToScreen(message.data);
//   }

//   /// Logs notification details for debugging
//   void _logNotificationDetails(RemoteMessage message) {
//     debugPrint('Message data: ${message.data}');

//     if (message.notification != null) {
//       debugPrint('Notification Title: ${message.notification?.title}');
//       debugPrint('Notification Body: ${message.notification?.body}');
//       debugPrint('Notification Data: ${message.data}');
//     }
//   }
// }
