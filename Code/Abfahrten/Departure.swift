import Foundation


/// A departure
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
struct Departure: CustomStringConvertible, CustomDebugStringConvertible {
    // MARK: - Properties
    let line: String
    let type: Type
    let direction: String
    let time: String
    let delay: Int
    let platform: String
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
    var debugDescription: String {
        return "Departure of \"\(line)\" with a \"\(type.name())\" to \"\(direction)\" at \"\(time)\" with a delay of \"\(delay)\" minutes from platform \"\(platform)\""
    }
    
    
    
    // MARK: - Initialization
    init(of line: String, with type: Type, to direction: String, at time: String) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = 0
        self.platform = ""
    }
    
    
    init(of line: String, with type: Type, to direction: String, at time: String, from platform: String) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = 0
        self.platform = platform
    }
    
    
    init(of line: String, with type: Type, to direction: String, at time: String, with delay: Int) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = delay
        self.platform = ""
    }
    
    
    init(of line: String, with type: Type, to direction: String, at time: String, with delay: Int, from platform: String) {
        self.line = line
        self.type = type
        self.direction = direction
        self.time = time
        self.delay = delay
        self.platform = platform
    }
}
