import SwiftUI
import UIKit

@main
struct MyCarPlayBrowserApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(AppSettings.shared.theme == .dark ? .dark : .light)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if connectingSceneSession.role == .carTemplateApplication {
            let configuration = UISceneConfiguration(name: "CarPlay", sessionRole: .carTemplateApplication)
            configuration.delegateClass = CarPlaySceneDelegate.self
            return configuration
        }

        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: .windowApplication)
        configuration.delegateClass = AppSceneDelegate.self
        return configuration
    }
}

final class AppSceneDelegate: UIResponder, UIWindowSceneDelegate {}
