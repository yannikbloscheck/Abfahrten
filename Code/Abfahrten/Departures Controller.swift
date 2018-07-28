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
    var station: Station? = nil
    
    
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
            return [UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(searchBarCancelButtonClicked(_:)))]
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
        }
    }
    
    
    
    // MARK: - Main
    
    /// Update the departures
    @IBAction func update() {
        updateWithTitle(false)
    }
    
    
    /// Update the departures with completion handler
    private func updateWithTitle(_ includingTitle: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            if self.searchTerm.isEmpty {
                if let location = self.locationManager.location {
                    self.coordinate = location.coordinate
                }
                
                Server.station(for: self.coordinate, completion: { (station) in
                    self.station = station
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5) {
                            self.loadingDepartures.isHidden = true
                            
                            self.tableView.reloadData()
                            self.tableView.refreshControl?.endRefreshing()
                            
                            if includingTitle {
                                self.searchBar.text = self.station?.name
                            }
                        }
                    }
                })
            } else {
                Server.station(with: self.searchTerm, completion: { (station) in
                    self.station = station
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.5) {
                            self.loadingDepartures.isHidden = true
                            
                            self.tableView.reloadData()
                            self.tableView.refreshControl?.endRefreshing()
                            
                            if includingTitle {
                                self.searchBar.text = self.station?.name
                            }
                        }
                    }
                })
            }
        }
    }
    
    
    
    // MARK: - View Controller
    
    /// Do any additional setup after loading the view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.backgroundColor = UIColor(named: "Background Color")!
        refreshControl.addTarget(self, action: #selector(update), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        loadingDepartures.isHidden = false
        noDepartures.isHidden = true
        
        Server.station(for: coordinate, completion: { (station) in
            self.station = station
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.5) {
                    self.loadingDepartures.isHidden = true
                    
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        })
        
        updateTimer = Timer(timeInterval: 60, repeats: true, block: { (_) in
            self.update()
        })
        RunLoop.current.add(updateTimer, forMode: RunLoop.Mode.common)
        
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
        } else if let station = self.station, station.departures.count > 0 {
            noDepartures.isHidden = true
            
            return station.departures.count
        } else {
            noDepartures.isHidden = false
            
            return 0
        }
    }
    
    
    /// Create the cell for an index path
    ///
    /// - Parameter tableView: The table view
    /// - Parameter indexPath: The index path
    /// - Returns: The cell for a specific index path
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let station = self.station, let cell = tableView.dequeueReusableCell(withIdentifier: "Departure", for: indexPath) as? DepartureCell {
            let departure = station.departures[indexPath.row]
            
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
            
            cell.type.image = departure.type.symbol
            
            cell.line.text = departure.line
            
            cell.direction.text = departure.direction
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            cell.time.text = timeFormatter.string(from: departure.time)
            
            if departure.delay > 60 {
                if !departure.platform.isEmpty {
                    cell.platform.text = NSLocalizedString("PLATFORM", comment: "Platform") + " \(departure.platform ), +\(departure.delay/60)"
                } else {
                    cell.platform.text = "+\(departure.delay/60)"
                }
                
                cell.time.textColor = UIColor(named: "Alert Color")!
                cell.platform.textColor = UIColor(named: "Alert Color")!
            } else {
                cell.time.textColor = UIColor(named: "Tint Color")!
                cell.platform.textColor = UIColor(named: "Tint Color")!
                
                if !departure.platform.isEmpty {
                    cell.platform.text = NSLocalizedString("PLATFORM", comment: "Platform") + " \(departure.platform)"
                } else {
                    cell.platform.text = ""
                }
            }
            
            return cell
        } else {
            let cell =  UITableViewCell()
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            return cell
        }
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
    
    
    /// Handle a authorization status
    ///
    /// - Parameter manager: The location manager
    /// - Parameter status: The authorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() && (status != .restricted && status != .denied) && CLLocationManager.significantLocationChangeMonitoringAvailable() {
            locationManager = CLLocationManager()
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
}

