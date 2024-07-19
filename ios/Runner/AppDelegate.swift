import UIKit
import Flutter
import CoreLocation
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  
  private var locationManager = CLLocationManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    print(".........");
    // Set up location manager
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.allowsBackgroundLocationUpdates = true
    let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575), radius: 100, identifier: "Office")
    locationManager.startMonitoring(for: region)
    
    application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
     print("aaaaaaa")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 
  override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    // Handle background fetch
    completionHandler(.newData)
  }
    
  // CLLocationManagerDelegate method
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    // Notify the app when entering the region
    let content = UNMutableNotificationContent()
    content.title = "Punch Reminder"
    content.body = "Don't forget to punch in------!"
    content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "clock.aiff"))
    
    let request = UNNotificationRequest(identifier: "GeofenceAlarm", content: content, trigger: nil)
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
  }
}
