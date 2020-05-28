import Foundation
import UIKit
import SwiftUI


/// Delegate of the scene
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2020-05-28
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	// MARK: - Properties
	
	// The window
	var window: UIWindow?
	
	// The station manager
	var stationManager = StationManager()
	
	
	
	// MARK: - Scene Delegate
	
	/// Configure and attach the window to the scene
	/// - Parameter scene: The scene
	/// - Parameter session: The scene session
	/// - Parameter connectionOptions: The scene connection options
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		if let windowScene = scene as? UIWindowScene {
			let controller = UIHostingController(rootView: DeparturesView(stationManager: stationManager))
			controller.view.backgroundColor = UIColor(named: "Dark Background Color")
			
			let window = UIWindow(windowScene: windowScene)
			window.rootViewController = controller
			self.window = window
			window.makeKeyAndVisible()
		}
    }
	
	
	/// Release any resources associated with the scene  that can be re-created on reconnection
	/// - Parameter scene: The scene
    func sceneDidDisconnect(_ scene: UIScene) {}
	
	
	/// Restart any tasks that were paused
	/// - Parameter scene: The scene
    func sceneDidBecomeActive(_ scene: UIScene) {}
	
	
	/// Pause ongoing tasks because there are temporary interruptions (such as an incoming phone call)
	/// - Parameter scene: The scene
    func sceneWillResignActive(_ scene: UIScene) {}
	
	
	/// Undo changes made on entering the background
	/// - Parameter scene: The scene
    func sceneWillEnterForeground(_ scene: UIScene) {}
	
	
	/// Release shared resouces and store everything
	/// - Parameter scene: The scene
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
