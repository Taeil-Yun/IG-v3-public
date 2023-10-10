import UIKit
import Flutter
import NaverThirdPartyLogin
import AppTrackingTransparency

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
//    // This is required to make any communication available in the action isolate.
//    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//      GeneratedPluginRegistrant.register(with: registry)
//    }
      
    // notification 권한 설정
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                print("Permission granted: \(granted)")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    registerForPushNotifications()
      
    GeneratedPluginRegistrant.register(with: self)
      
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
    }
      
    let controller = window.rootViewController as! FlutterViewController

    let flavorChannel = FlutterMethodChannel(name: "flavor", binaryMessenger: controller.binaryMessenger)

    flavorChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        let flavor = Bundle.main.infoDictionary?["APP FLAVOR"]
        result(flavor)
    })
      
    // 앱 추적 투명성
    requestPermission()
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  func requestPermission() {
      if #available(iOS 14, *) {
          ATTrackingManager.requestTrackingAuthorization {
              status in
              switch status {
              case .authorized:
                  print("we got permission")
              case .notDetermined:
                  print("the user has not yet received an authorization request")
              case .restricted:
                  print("the permission we get are restricted")
              case .denied:
                  print("we didn't get the permission")
              @unknown default:
                  print("looks like we didn't get permission")
              }
          }
      } else {
          // Fallback on earlier versions
      }
  }
    
  // naver login
  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
      var applicationResult = false
      if (!applicationResult) {
          applicationResult = NaverThirdPartyLoginConnection.getSharedInstance().application(app, open: url, options: options)
          
      }
      // 다른 응용 프로그램 url 프로세스를 사용하는 경우 여기에 코드를 추가
      if (!applicationResult) {
          applicationResult = super.application(app, open: url, options: options)
          
      }
      return applicationResult
  }
}
