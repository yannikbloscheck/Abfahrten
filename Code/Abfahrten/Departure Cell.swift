import Foundation
import UIKit


/// Cell to display a departure
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
class DepartureCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet var timeHeight: NSLayoutConstraint!
    @IBOutlet var type: UIImageView!
    @IBOutlet var line: UILabel!
    @IBOutlet var direction: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var platform: UILabel!
}
