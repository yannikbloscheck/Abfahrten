import Foundation
import UIKit
import CoreLocation


/// Main view controller of the application, which displays the departures
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
class DeparturesController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
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
    
    /// The indicator to display when there are departures loading
    @IBOutlet var loadingDepartures: UIActivityIndicatorView!
    
    /// The label to display when there are no departures
    @IBOutlet var noDepartures: UILabel!
    
    /// Keyboard shortcuts
    override var keyCommands: [UIKeyCommand]? {
        get {
            return [UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: #selector(searchBarTextDidEndEditing))]
        }
    }
    
    
    
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
            
            if UserDefaults.standard.object(forKey: "Type Limit") == nil {
                UserDefaults.standard.set(6, forKey: "Type Limit")
            }
        }
    }
    
    
    
    // MARK: - Main
    
    /// Update the departures
    @IBAction func update() {
        updateWithTitle(false)
    }
    
    
    /// Update the departures with completion handler
    private func updateWithTitle(_ updateTitle: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            if self.searchTerm.isEmpty {
                if let location = self.locationManager.location {
                    self.coordinate = location.coordinate
                }
                
                if UserDefaults.standard.integer(forKey: "Type Limit") == 6 {
                    self.departures = Departures(coordinate: self.coordinate, number: 50)
                } else {
                    self.departures = Departures(coordinate: self.coordinate, number: 50, type: Type(rawValue: UserDefaults.standard.integer(forKey: "Type Limit"))!)
                }
            } else {
                if UserDefaults.standard.integer(forKey: "Type Limit") == 6 {
                    self.departures = Departures(searchTerm: self.searchTerm, number: 50)
                } else {
                    self.departures = Departures(searchTerm: self.searchTerm, number: 50, type: Type(rawValue: UserDefaults.standard.integer(forKey: "Type Limit"))!)
                }
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.loadingDepartures.isHidden = true
                    
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                    
                    if updateTitle {
                        self.searchBar.text = self.departures.station
                    }
                }
            }
            
            if self.departures.count == 0 && UserDefaults.standard.integer(forKey: "Type Limit") != 6 {
                UserDefaults.standard.set(6, forKey: "Type Limit")
                self.update()
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
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.backgroundColor = UIColor(named: "Background Color")!
        refreshControl.addTarget(self, action: #selector(update), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        
        loadingDepartures.isHidden = false
        noDepartures.isHidden = true
        
        departures = Departures(coordinate: coordinate, number: 50)
        
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
        if !loadingDepartures.isHidden {
            noDepartures.isHidden = true
            
            return 0
        } else {
            let count = departures.count
            if count < 1 {
                noDepartures.isHidden = false
            } else {
                noDepartures.isHidden = true
            }
            return count
        }
    }
    
    
    /// Create the cell for an index path
    ///
    /// - Parameter tableView: The table view
    /// - Parameter indexPath: The index path
    /// - Returns: The cell for a specific index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let departure = departures[indexPath.row]!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Departure", for: indexPath) as! DepartureCell
        
        
        if traitCollection.userInterfaceIdiom == .pad && self.view.bounds.size.width > 640 {
            cell.line.font = cell.line.font.withSize(22)
            cell.direction.font = cell.direction.font.withSize(14)
            cell.time.font = cell.time.font.withSize(22)
            cell.platform.font = cell.platform.font.withSize(14)
        } else {
            cell.line.font = cell.line.font.withSize(19)
            cell.direction.font = cell.direction.font.withSize(12)
            cell.time.font = cell.time.font.withSize(19)
            cell.platform.font = cell.platform.font.withSize(12)
        }
        
        cell.type.image = departure.type.glyph
        cell.line.text = departure.line
        cell.direction.text = departure.direction
        cell.time.text = departure.time
        
        if departure.delay > 1 {
            cell.time.textColor = UIColor(named: "Alert Color")!
            cell.platform.textColor = UIColor(named: "Alert Color")!
        } else {
            cell.time.textColor = UIColor(named: "Tint Color")!
            cell.platform.textColor = UIColor(named: "Tint Color")!
        }
        
        if departure.platform.isEmpty {
            if departure.delay > 1 {
                cell.platform.text = "+\(departure.delay)"
            } else {
                cell.platform.text = ""
            }
        } else {
            cell.platform.text = "Gleis " + departure.platform
            
            if departure.delay > 1 {
                cell.platform.text = cell.platform.text! + ", +\(departure.delay)"
            }
        }
        
        return cell
    }
    
    
    
    // MARK: - Table View Delegate
    
    /// Return the height for a cell in the table view
    ///
    /// - Parameter tableView: The table view
    /// - Parameter indexPath: The index path
    /// - Returns: The height for a cell at a specific index path
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if traitCollection.userInterfaceIdiom == .pad && self.view.bounds.size.width > 640 {
            return 70
        } else {
            return 60
        }
    }
    
    
    
    // MARK: - Search Bar Delegate
    
    /// Handle that the search button was clicked
    ///
    /// - Parameter searchBar: The search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTerm = searchBar.text
        self.searchBar.resignFirstResponder()
        
        noDepartures.isHidden = true
        loadingDepartures.isHidden = false
        self.tableView.reloadData()
        
        updateWithTitle(true)
    }
    
    
    /// Handle that the cancel button was clicked
    ///
    /// - Parameter searchBar: The search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.text = ""
        searchTerm = ""
        self.searchBar.resignFirstResponder()
        
        noDepartures.isHidden = true
        loadingDepartures.isHidden = false
        self.tableView.reloadData()
        
        update()
    }
    
    
    /// Handle that text editing ended
    ///
    /// - Parameter searchBar: The search bar
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let searchText = self.searchBar.text, searchText.isEmpty {
            self.searchBar.text = ""
            searchTerm = ""
            self.searchBar.resignFirstResponder()
            
            noDepartures.isHidden = true
            loadingDepartures.isHidden = false
            self.tableView.reloadData()
            
            update()
        } else {
            self.searchBar.resignFirstResponder()
        }
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

