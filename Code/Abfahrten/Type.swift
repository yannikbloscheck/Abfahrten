import Foundation
import UIKit


/// Different types of transportation
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
enum Type: Int {
    case countryTrain = 0
    case regionTrain = 1
    case cityTrain = 2
    case underground = 3
    case tram = 4
    case bus = 5
    
    
    
    // MARK: - Main
    
    /// Get the name of the type of transportation
    ///
    /// - Returns: Name of the type
    func name() -> String {
        switch self {
        case .countryTrain:
            return "Country Train"
        case .regionTrain:
            return "Region Train"
        case .cityTrain:
            return "City Train"
        case .underground:
            return "Underground"
        case .tram:
            return "Tram"
        case .bus:
            return "Bus"
        }
    }
    
    
    /// Get a glyph for the type of transportation
    ///
    /// - Returns: Glyph for the type
    func glyph() -> UIImage {
        switch self {
        case .countryTrain:
            return #imageLiteral(resourceName: "Country Train")
        case .regionTrain:
            return #imageLiteral(resourceName: "Region Train")
        case .cityTrain:
            return #imageLiteral(resourceName: "City Train")
        case .underground:
            return #imageLiteral(resourceName: "Underground")
        case .tram:
            return #imageLiteral(resourceName: "Tram")
        case .bus:
            return #imageLiteral(resourceName: "Bus")
        }
    }
    
    
    /// Check if the description matches the type of transportation
    ///
    /// - Parameter description: A description of a connection
    /// - Returns: `true` if the description matches the type of transportation or `false` if not
    func matches(description: String) -> Bool {
        for term in terms() {
            if description.uppercased().contains(term.uppercased()) {
                return true
            }
        }
        
        for term in terms() {
            if description.uppercased().contains(term.uppercased().trimmingCharacters(in: .whitespacesAndNewlines)) {
                return true
            }
        }
        
        return false
    }
    
    
    /// Get different terms, which describe the type of transportation
    ///
    /// - Returns: Terms descriping the type
    private func terms() -> [String] {
        switch self {
        case .countryTrain:
            return ["ICE ", "IC ", "EC "]
        case .regionTrain:
            return ["RE ", " R", "RB"]
        case .cityTrain:
            return ["S ", "S-Bahn"]
        case .underground:
            return ["U ", "U-Bahn"]
        case .tram:
            return ["Tram ","STR ","STB "]
        case .bus:
            return ["Bus","RUF"]
        }
    }
}
