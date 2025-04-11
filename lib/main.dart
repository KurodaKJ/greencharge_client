import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

/// The entry point of the application.
void main() async {
  // Ensure Flutter's engine is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure background message handling.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set up token refresh listener.
  _setupTokenRefreshListener();

  // Run the application.
  runApp(const MainApp());
}

/// Handles incoming messages in the background.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message here.
  log('Handling a background message: ${message.messageId}');

  // Initialize Firebase if it's not already.
  await Firebase.initializeApp();
}

/// Sets up a listener for FCM token refresh events.
void _setupTokenRefreshListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    log('New FCM Token: $newToken');
    // Here you should send the new token to your server.
    _sendTokenToServer(newToken);
  });
}

/// Simulates sending the FCM token to a server.
void _sendTokenToServer(String token) {
  // Implement the logic to send the token to your server here.
  log("Sending token to server: $token");
  // Replace the log with the actual http call to your server.
}

/// The root widget for the application.
class MainApp extends StatelessWidget {
  /// Constructor for the MainApp widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomeView(title: 'Flutter FCM Demo'),
    );
  }
}

/// The main screen of the application.
class HomeView extends StatefulWidget {
  /// Constructor for the HomeView widget.
  const HomeView({super.key, required this.title});

  /// The title of the application.
  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _fcmToken = "No token yet";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getAndDisplayToken();
  }

  /// Retrieves the FCM token and updates the UI.
  Future<void> _getAndDisplayToken() async {
    _startLoading();
    try {
      final token = await FirebaseMessaging.instance.getToken();
      _updateToken(token);
    } catch (e) {
      log('Error fetching FCM token: $e');
      //Display an error to the user (snackbar, alert, etc)
    } finally {
      _stopLoading();
    }
  }

  /// Updates the displayed FCM token and logs the new token.
  void _updateToken(String? token) {
    if (token != null) {
      setState(() {
        _fcmToken = token;
      });
      log('FCM Token: $_fcmToken');
    }
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade600],
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('FCM Token:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                      const SizedBox(height: 10),
                      SelectableText(_fcmToken, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _getAndDisplayToken,
                        child: const Text("Refresh Token"),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}