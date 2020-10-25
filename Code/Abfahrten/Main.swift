import Foundation
import SwiftUI


/// Main for the application
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2020-06-25
@main
struct Main: App {
	// MARK: Properties
	
	/// The station manager
	@StateObject var stationManager = StationManager()
	
	
	
	/// The actual scene
	@SceneBuilder var body: some Scene {
		WindowGroup {
			DeparturesView(stationManager: stationManager)
		}
	}
}

