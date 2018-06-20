import Foundation
import UIKit


/// Different types of transportation
///
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
    ///
    /// - Returns: Symbol for the type
    var symbol: UIImage {
        get {
            switch self {
            case .countryTrain:
                return #imageLiteral(resourceName: "Types/Country Train")
            case .regionTrain:
                return #imageLiteral(resourceName: "Types/Region Train")
            case .cityTrain:
                return #imageLiteral(resourceName: "Types/City Train")
            case .underground:
                return #imageLiteral(resourceName: "Types/Underground")
            case .tram:
                return #imageLiteral(resourceName: "Types/Tram")
            case .bus:
                return #imageLiteral(resourceName: "Types/Bus")
            }
        }
    }
}
