import Foundation


/// Different types of transportation
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
enum Type: String, Codable {
    case countryTrain = "Country Train"
    case regionTrain = "Region Train"
    case cityTrain = "City Train"
    case underground = "Underground"
    case tram = "Tram"
    case bus = "Bus"
    
    
	
    /// Get a symbol for the type of transportation
    /// - Returns: Symbol for the type
    var symbol: String {
        get {
			return "Types/\(rawValue)"
        }
    }
}
