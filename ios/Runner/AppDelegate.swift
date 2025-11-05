import UIKit
import Flutter
import GoogleMaps
import background_locator_2
import flutter_local_notifications
import FirebaseCore
import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // 🌍 Google Maps API Key
        GMSServices.provideAPIKey(AIzaSyD9m5C9Rv4NzTd-1EUB1mc5cK82oseZA6M)
        
        // 🔥 Initialize Firebase (for push notifications)
        FirebaseApp.configure()
        
        // 🛰 Initialize Background Locator
        SwiftBackgroundLocatorPlugin.setPluginRegistrantCallback { registry in
            // This ensures the plugin is correctly registered for background execution
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        // 🔔 Local Notifications Setup
        UNUserNotificationCenter.current().delegate = self
        
        // ✅ Flutter Setup
        GeneratedPluginRegistrant.register(with: self)
        
        // 🧭 Request notification permissions
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
        }
        
        application.registerForRemoteNotifications()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // 🔔 Handle FCM token refresh
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📩 FCM token: \(String(describing: fcmToken))")
    }
    
    // 🧭 Handle foreground notification
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }
}
