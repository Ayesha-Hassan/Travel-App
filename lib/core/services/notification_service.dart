import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_travel_companion/domain/entities/place.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showTripReminder(Place place) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'trip_reminders',
      'Trip Reminders',
      channelDescription: 'Reminders for your travel destinations',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      place.id,
      'Trip Reminder: ${place.title}',
      'Don\'t forget your trip to ${place.location}!',
      platformChannelSpecifics,
    );
  }
}
