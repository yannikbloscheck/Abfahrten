import Foundation
import CoreLocation


/// Gets the station from the API
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2018-06-18
class StationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
	// MARK: - Properties
	
	/// The location manager
	var locationManager: CLLocationManager = CLLocationManager()
    
    
    /// The coordinate from which to find the nearest station
    var coordinate: CLLocationCoordinate2D?
	
	
	/// Did the station change?
	@Published var hasNewStation: Bool = true
	
	
	/// The current station
	@Published var station: Station? = nil
	
	
	
	// MARK: - Initialization
	override init() {
		super.init()
		
		// Setup the location manager
		if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() != .restricted && CLLocationManager.authorizationStatus() != .denied) && CLLocationManager.significantLocationChangeMonitoringAvailable() {

			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.distanceFilter = 20
			locationManager.requestAlwaysAuthorization()
			locationManager.startMonitoringSignificantLocationChanges()
			
			if let currentCoordinate = locationManager.location?.coordinate {
				coordinate = currentCoordinate
			}
		}
	}
	
	
	
	// MARK: - Main
    
    /// Find the station nearest to the coordinate
    ///
    /// - Parameter coordinate: A coordinate
    /// - Parameter completion: Do something with the result
    func refreshStation(for coordinate: CLLocationCoordinate2D, completion: @escaping () -> Void) {
        if let url = URL(string: "https://api.yannikbloscheck.com/abfahrten/2.0/station/by-location/\(coordinate.latitude),\(coordinate.longitude)/") {
			refreshStation(with: url, completion: completion)
        } else {
			self.hasNewStation = false
            self.station = nil
			completion()
        }
    }
    
    
    /// Find the station with the given name
    ///
    /// - Parameter name: A station name to find
    /// - Parameter completion: Do something with the result
    func refreshStation(with name: String, completion: @escaping () -> Void) {
		if name.isEmpty, let coordinate = coordinate {
			refreshStation(for: coordinate, completion: completion)
		} else if let encodedName = name.trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .alphanumerics), let url = URL(string: "https://api.yannikbloscheck.com/abfahrten/2.0/station/by-name/\(encodedName)/") {
            refreshStation(with: url, completion: completion)
        } else {
			self.hasNewStation = false
            self.station = nil
			completion()
        }
    }
    
    
    /// Find the station using the given url
    ///
    /// - Parameter url: An url to an API endpoint
    /// - Parameter completion: Do something with the result
    private func refreshStation(with url: URL, completion: @escaping () -> Void) {
        let urlRequest = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60)
        URLSession.shared.dataTask(with: urlRequest) { (data, _, _) in
			let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            if let json = data, let station = try? jsonDecoder.decode(Station.self, from: json) {
				DispatchQueue.main.async {
					self.hasNewStation = false
					self.station = station
					completion()
				}
            } else {
				DispatchQueue.main.async {
					self.hasNewStation = false
					self.station = nil
					completion()
				}
            }
        }.resume()
    }
	
	
	
	// MARK: - Location Manager Delegate
	
	/// Handle new location data
	///
	/// - Parameter manager: The location manager
	/// - Parameter locations: The updated locations
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		coordinate = locations.last?.coordinate
		if let currentCoordinate = coordinate {
			refreshStation(for: currentCoordinate){}
		}
	}
	
	
	/// Handle an error while receiving locations
	///
	/// - Parameter manager: The location manager
	/// - Parameter error: The error
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		 print(error.localizedDescription)
	}
	
	
	/// Handle a authorization status
	///
	/// - Parameter manager: The location manager
	/// - Parameter status: The authorization status
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if CLLocationManager.locationServicesEnabled() && (status != .restricted && status != .denied) && CLLocationManager.significantLocationChangeMonitoringAvailable() {
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.distanceFilter = 20
			locationManager.startMonitoringSignificantLocationChanges()
			
			if let currentCoordinate = locationManager.location?.coordinate {
				coordinate = currentCoordinate
			}
		}
	}
}
