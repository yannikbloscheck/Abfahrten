import Foundation
import UIKit
import CoreLocation


/// Main view controller of the application, which displays the departures
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
class DeparturesController: UIViewController, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    // MARK: - Properties
    
    /// The location manager
    var locationManager: CLLocationManager!
    
    /// A coordinate from which to find the nearest station
    var coordinate: CLLocationCoordinate2D!
    
    /// A station name to find
    var searchTerm: String! = ""
    
    /// The departures
    var departures: Departures!
    
    /// The timer for updating the departures
    var updateTimer: Timer = Timer()
    
    /// The search bar
    @IBOutlet var searchBar: UISearchBar!
    
    /// The table view
    @IBOutlet var tableView: UITableView!
    
    /// The label to display when there are no departures
    @IBOutlet var noDepartures: UILabel!
    
    
    
    // MARK: - Initialization
    
    /// Initalize a departures controller
    ///
    /// - Parameter coder: A coder
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        coordinate = CLLocationCoordinate2D(latitude: 53.552812, longitude: 10.006979)
        
        if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() != .restricted && CLLocationManager.authorizationStatus() != .denied) && CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.distanceFilter = 20
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringSignificantLocationChanges()
            
            if let currentCoordinate = locationManager.location?.coordinate {
                coordinate = currentCoordinate
            }
            
            departures = Departures(coordinate: coordinate, number: 50)
            
            if UserDefaults.standard.object(forKey: "Type Limit") == nil {
                UserDefaults.standard.set(6, forKey: "Type Limit")
            }
        }
    }
    
    
    
    // MARK: - Main
    
    /// Update the departures
    @IBAction func update() {
        if searchTerm.isEmpty {
            if let newCoordinate = locationManager.location?.coordinate {
                coordinate = newCoordinate
            }
            
            if UserDefaults.standard.integer(forKey: "Type Limit") == 6 {
                departures = Departures(coordinate: coordinate, number: 50)
            } else {
                departures = Departures(coordinate: coordinate, number: 50, type: Type(rawValue: UserDefaults.standard.integer(forKey: "Type Limit"))!)
            }
        } else {
            if UserDefaults.standard.integer(forKey: "Type Limit") == 6 {
                departures = Departures(searchTerm: searchTerm, number: 50)
            } else {
                departures = Departures(searchTerm: searchTerm, number: 50, type: Type(rawValue: UserDefaults.standard.integer(forKey: "Type Limit"))!)
            }
        }
        
        if departures.count == 0 && UserDefaults.standard.integer(forKey: "Type Limit") != 6 {
            updateTypeLimit()
        } else {
            UIView.animate(withDuration: 0.5) {
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    /// Update the type limit
    @IBAction func updateTypeLimit() {
        if UserDefaults.standard.integer(forKey: "Type Limit") == 0 {
            UserDefaults.standard.set(6, forKey: "Type Limit")
        } else {
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "Type Limit")-1, forKey: "Type Limit")
        }
        
        self.update()
    }
    
    
    
    // MARK: - View Controller
    
    /// Do any additional setup after loading the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        refreshControl.backgroundColor = #colorLiteral(red: 0.9360449314, green: 0.9360449314, blue: 0.9360449314, alpha: 1)
        refreshControl.addTarget(self, action: #selector(update), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        
        updateTimer = Timer(timeInterval: 60, repeats: true, block: { (_) in
            self.update()
        })
        RunLoop.current.add(updateTimer, forMode: RunLoopMode.commonModes)
        
        self.view.setNeedsLayout()
    }
    
    
    /// Dispose of any resources that can be recreated
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    // MARK: - Table View Data Source
    
    /// Return the number of sections in the table view
    ///
    /// - Parameter tableView: The table view
    /// - Returns: The number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    /// Return the number of rows in a section of the table view
    ///
    /// - Parameter tableView: The table view
    /// - Parameter section: The section
    /// - Returns: The number of rows in a section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = departures.count
        if count < 1 {
            noDepartures.isHidden = false
        } else {
            noDepartures.isHidden = true
        }
        return count
    }
    
    
    /// Create the cell for an index path
    ///
    /// - Parameter tableView: The table view
    /// - Parameter indexPath: The index path
    /// - Returns: The cell for a specific index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let departure = departures[indexPath.row]!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Departure", for: indexPath) as! DepartureCell
        
        cell.type.image = departure.type.glyph()
        cell.line.text = departure.line
        cell.direction.text = departure.direction
        cell.time.text = departure.time
        
        if departure.delay > 1 {
            cell.time.textColor = #colorLiteral(red: 0.6167115654, green: 0.07720391789, blue: 0.007754685425, alpha: 1)
            cell.platform.textColor = #colorLiteral(red: 0.6167115654, green: 0.07720391789, blue: 0.007754685425, alpha: 1)
        } else {
            cell.time.textColor = #colorLiteral(red: 0.01473352102, green: 0.1297693814, blue: 0.2014771978, alpha: 1)
            cell.platform.textColor = #colorLiteral(red: 0.01473352102, green: 0.1297693814, blue: 0.2014771978, alpha: 1)
        }
        
        if departure.platform.isEmpty {
            if departure.delay > 1 {
                cell.timeHeight.constant = 24
                cell.platform.text = "+\(departure.delay)"
            } else {
                cell.timeHeight.constant = 35
                cell.platform.text = ""
            }
        } else {
            cell.timeHeight.constant = 24
            cell.platform.text = "Gleis " + departure.platform
            
            if departure.delay > 1 {
                cell.platform.text = cell.platform.text! + ", +\(departure.delay)"
            }
        }
        
        return cell
    }
    
    
    
    // MARK: - Search Bar Delegate
    
    /// Handle that the search button was clicked
    ///
    /// - Parameter searchBar: The search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTerm = searchBar.text
        searchBar.resignFirstResponder()
        update()
        searchBar.text = departures.station
    }
    
    
    /// Handle that the cancel button was clicked
    ///
    /// - Parameter searchBar: The search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchTerm = ""
        searchBar.resignFirstResponder()
        update()
    }
    
    
    
    // MARK: - Location Manager Delegate
    
    /// Handle new location data
    ///
    /// - Parameter manager: The location manager
    /// - Parameter locations: The updated locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
        update()
    }
    
    
    /// Handle an error while receiving locations
    ///
    /// - Parameter manager: The location manager
    /// - Parameter error: The error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}

