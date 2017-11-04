import Foundation


/// A departure
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
struct Departure: CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: - Properties
    
    /// The line that will depart
    let line: String
    
    /// The type of transportation that will depart
    let type: Type
    
    /// The direction in which the line will depart
    let direction: String
    
    /// The time when the line will depart
    let time: String
    
    /// The delay with which the line will depart
    let delay: Int
    
    /// The platform where the line will depart from
    let platform: String
    
    /// A description of the departure
    var description: String {
        var description = "Departure of \(line) with a \(type.name().lowercased()) to \(direction) at \(time)"
        if delay > 1 {
            description = description + " with a delay of \(delay) minutes"
        }
        if platform.isEmpty {
            description = description + " from platform \(platform)"
        }
        return description
    }
    
    /// A description of the departure for debugging
    var debugDescription: String {
        return "Departure of \"\(line)\" with a \"\(type.name())\" to \"\(direction)\" at \"\(time)\" with a delay of \"\(delay)\" minutes from platform \"\(platform)\""
    }
    
    
    
    // MARK: - Initialization
    
    /// Initalize a departure
    ///
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter time: A time when the line will depart
    init(of line: String, with type: Type, to direction: String, at time: String) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = 0
        self.platform = ""
    }
    
    
    /// Initalize a departure
    ///
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter time: A time when the line will depart
    /// - Parameter platform: A platform where the line will depart from
    init(of line: String, with type: Type, to direction: String, at time: String, from platform: String) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = 0
        self.platform = platform
    }
    
    
    /// Initalize a departure
    ///
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter time: A time when the line will depart
    /// - Parameter delay: A delay with which the line will depart
    init(of line: String, with type: Type, to direction: String, at time: String, with delay: Int) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = delay
        self.platform = ""
    }
    
    
    /// Initalize a departure
    ///
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter time: A time when the line will depart
    /// - Parameter delay: A delay with which the line will depart
    /// - Parameter platform: A platform where the line will depart from
    init(of line: String, with type: Type, to direction: String, at time: String, with delay: Int, from platform: String) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = delay
        self.platform = platform
    }
}
