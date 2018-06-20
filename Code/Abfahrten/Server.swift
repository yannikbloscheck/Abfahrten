import Foundation
import CoreLocation


/// Parses the departures from the website
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2018-06-18
struct Server {
    // MARK: - Main
    
    /// Find the station nearest to the coordinate
    ///
    /// - Parameter coordinate: A coordinate
    /// - Parameter completion: Do something with the result
    static func station(for coordinate: CLLocationCoordinate2D, completion: @escaping (Station?) -> Void) {
        if let url = URL(string: "https://apps.yannikbloscheck.com/abfahrten/api/1.0/station-by-location/\(coordinate.latitude),\(coordinate.longitude)/") {
            station(with: url, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    
    /// Find the station with the given name
    ///
    /// - Parameter searchTerm: A station name to find
    /// - Parameter completion: Do something with the result
    static func station(with name: String, completion: @escaping (Station?) -> Void) {
        if let url = URL(string: "https://apps.yannikbloscheck.com/abfahrten/api/1.0/station-by-name/\(name)/") {
            station(with: url, completion: completion)
        } else {
            completion(nil)
        }
    }
    
    
    /// Find the station using the given url
    ///
    /// - Parameter url: An url to an API endpoint
    /// - Parameter completion: Do something with the result
    static private func station(with url: URL, completion: @escaping (Station?) -> Void) {
        let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60)
        URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .secondsSince1970
            if let json = data, let station = try? jsonDecoder.decode(Station.self, from: json) {
                completion(station)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
