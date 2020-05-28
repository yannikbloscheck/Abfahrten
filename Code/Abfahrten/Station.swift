import Foundation


/// A station
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2018-06-18
struct Station: Equatable, Codable {
    // MARK: - Properties
    
    /// The name of the station
    let name: String
    
    /// The creation date of the data
    let date: Date
    
    /// The departures from the station
    let departures: [Departure]
    
    
    
    // MARK: - Initialization
    
    /// Initalize a departure
    ///
    /// - Parameter name: A name for the station
	/// - Parameter date: A creation date of the data
    /// - Parameter departures: Departures from the station
    init(name: String, date: Date, departures: [Departure]) {
        self.name = name
		self.date = date
        self.departures = departures
    }
}
