import Foundation


/// A station
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2018-06-18
struct Station: Codable {
    // MARK: - Properties
    
    /// The name of the station
    let name: String
    
    /// The departures from the station
    let departures: [Departure]
    
    
    
    // MARK: - Initialization
    
    /// Initalize a departure
    ///
    /// - Parameter name: A name for the station
    /// - Parameter departures: Departures from the station
    init(name: String, departures: [Departure]) {
        self.name = name
        self.departures = departures
    }
}
