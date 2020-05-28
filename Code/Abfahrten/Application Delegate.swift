import Foundation
import UIKit


/// Delegate of the application
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
@UIApplicationMain class ApplicationDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Application Delegate
    
    /// Do things before the app is ready to run
    ///
    /// - Parameter application: The application
    /// - Parameter launchOptions: A dictionary indicating the reason the app was launched
    /// - Returns: `true` if the app should run or `false` if not
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
	
	
	/// Select a configuration to create the new scene with
	/// - Parameter application: The application
	/// - Parameter connectingSceneSession: The scene session
	/// - Parameter options: The scene connection options
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    
    /// Pause ongoing tasks because the application is about to move from active to inactive state as result of some temporary interruptions (such as an incoming phone call or SMS message) or the application will quit soon and therefore begins the transition to the background state.
    ///
    /// - Parameter application: The application
    func applicationWillResignActive(_ application: UIApplication) {}
    
    
    /// Release shared resouces and store everything.
    ///
    /// - Note: If your application supports background execution, this method is called instead of `applicationWillTerminate(application: UIApplication)` when the user quits
    /// - Parameter application: The application
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    
    /// Called as part of the transition from the background to the inactive state.
    ///
    /// - Note: Here you can undo many of the changes made on entering the background
    /// - Parameter application: The application
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    
    /// Restart any tasks that were paused (or not yet started) while the application was inactive.
    /// If the application was previously in the background, optionally refresh the user interface.
    ///
    /// - Parameter application: The application
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    
    /// Save changes in the application's managed object context before the application terminates.
    ///
    /// - Note: See also `applicationDidEnterBackground(application: UIApplication)`
    /// - Parameter application: The application
    func applicationWillTerminate(_ application: UIApplication) {}
}
