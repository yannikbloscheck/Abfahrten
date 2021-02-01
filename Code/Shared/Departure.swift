import Foundation


/// A departure
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
struct Departure: Identifiable, Hashable, Codable {
    // MARK: Properties
    
	/// The id
	let id: UUID = UUID()
	
	
	
    /// The line that will depart
    let line: String
    
    
	
    /// The type of transportation that will depart
    let type: Type
    
    
	
    /// The direction in which the line will depart
    let direction: String
    
	
    
    /// The date when the line will depart
    let date: Date
    
	
    
    /// The delay with which the line will depart
    let delay: Int?
    
	
    
    /// The platform where the line will depart from
    let platform: String?
    
    
	
    
    // MARK: Initialization
    
    /// Initalize a departure
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter date: A date when the line will depart
    init(of line: String, with type: Type, to direction: String, at date: Date) {
		self.line = line
        self.type = type
        self.direction = direction
        self.date = date
        self.delay = nil
        self.platform = nil
    }
    
	
    
    /// Initalize a departure
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter date: A date when the line will depart
    /// - Parameter platform: A platform where the line will depart from
    init(of line: String, with type: Type, to direction: String, at date: Date, from platform: String) {
		self.line = line
        self.type = type
        self.direction = direction
        self.date = date
        self.delay = nil
        self.platform = platform
    }
    
    
	
    /// Initalize a departure
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter date: A date when the line will depart
    /// - Parameter delay: A delay with which the line will depart
    init(of line: String, with type: Type, to direction: String, at date: Date, with delay: Int) {
		self.line = line
        self.type = type
        self.direction = direction
        self.date = date
        self.delay = delay
        self.platform = nil
    }
    
    
	
    /// Initalize a departure
    /// - Parameter line: A line that will depart
    /// - Parameter type: A type of transportation that will depart
    /// - Parameter direction: A direction in which the line will depart
    /// - Parameter date: A date when the line will depart
    /// - Parameter delay: A delay with which the line will depart
    /// - Parameter platform: A platform where the line will depart from
    init(of line: String, with type: Type, to direction: String, at date: Date, with delay: Int, from platform: String) {
		self.line = line
        self.type = type
        self.direction = direction
        self.date = date
        self.delay = delay
        self.platform = platform
    }
	
	
	
	
	// MARK: Coding Keys
 
	enum CodingKeys: CodingKey {
		case line
		case type
		case direction
		case date
		case delay
		case platform
	}
}
