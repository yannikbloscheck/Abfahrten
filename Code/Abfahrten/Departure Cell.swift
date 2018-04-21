import Foundation
import UIKit


/// Cell to display a departure
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
class DepartureCell: UITableViewCell {
    // MARK: - Properties
    
    /// The image for the type
    @IBOutlet var type: UIImageView!
    
    /// The line
    @IBOutlet var line: UILabel!
    
    /// The direction
    @IBOutlet var direction: UILabel!
    
    /// The time
    @IBOutlet var time: UILabel!
    
    /// The platform
    @IBOutlet var platform: UILabel!
}
