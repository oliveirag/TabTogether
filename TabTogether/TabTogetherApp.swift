

import SwiftUI
import FirebaseCore

// This class acts as the app's "delegate," handling initial setup.
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("FirebaseApp configured in AppDelegate.")
    return true
  }
}

@main
struct TabTogetherApp: App {
    // We register the AppDelegate here to ensure it's called on app launch.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
      WindowGroup {
        // Your root view goes here.
        ContentView()
      }
    }
  }
