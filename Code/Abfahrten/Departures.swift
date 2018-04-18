import Foundation
import CoreLocation


/// Parses the departures from the website
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2017-10-15
struct Departures {
    // MARK: - Properties
    
    /// The name of the current station
    var station: String = ""
    
    /// The next departures
    private var departures: [Departure]! = []
    
    /// The number of next departures
    var count: Int {
        return departures.count
    }
    
    
    
    // MARK: - Initialization
    
    /// Initalize departures
    ///
    /// - Parameter searchTerm: A station name to find
    /// - Parameter number: Number of departures to find
    init(searchTerm: String,  number: Int) {
        findDepartures(searchTerm: searchTerm, number: number, types: [.countryTrain, .regionTrain, .cityTrain, .underground, .tram, .bus])
    }
    
    
    /// Initalize departures
    ///
    /// - Parameter searchTerm: A station name to find
    /// - Parameter number: Number of departures to find
    /// - Parameter type: A type of transportation to find
    init(searchTerm: String, number: Int, type: Type) {
        findDepartures(searchTerm: searchTerm, number: number, types: [type])
    }
    
    
    /// Initalize departures
    ///
    /// - Parameter searchTerm: A station name to find
    /// - Parameter number: Number of departures to find
    /// - Parameter types: Types of transportation to find
    init(searchTerm: String, number: Int, types: [Type]) {
        findDepartures(searchTerm: searchTerm, number: number, types: types)
    }
    
    
    /// Initalize departures
    ///
    /// - Parameter coordinate: A coordinate from which to find the nearest station
    /// - Parameter number: Number of departures to find
    init(coordinate: CLLocationCoordinate2D,  number: Int) {
        findDepartures(coordinate: coordinate, number: number, types: [.countryTrain, .regionTrain, .cityTrain, .underground, .tram, .bus])
    }
    
    
    /// Initalize departures
    ///
    /// - Parameter coordinate: A coordinate from which to find the nearest station
    /// - Parameter number: Number of departures to find
    /// - Parameter type: A type of transportation to find
    init(coordinate: CLLocationCoordinate2D, number: Int, type: Type) {
        findDepartures(coordinate: coordinate, number: number, types: [type])
    }
    
    
    /// Initalize departures
    ///
    /// - Parameter coordinate: A coordinate from which to find the nearest station
    /// - Parameter number: Number of departures to find
    /// - Parameter types: Types of transportation to find
    init(coordinate: CLLocationCoordinate2D, number: Int, types: [Type]) {
        findDepartures(coordinate: coordinate, number: number, types: types)
    }
    
    
    
    // MARK: - Main
    
    /// Get the departure at an index
    ///
    /// - Parameter index: An index for which to get the departure
    /// - Returns: A departure if there is one
    subscript(index: Int) -> Departure? {
        if index <= departures.count-1 {
            return departures[index]
        } else {
            return nil
        }
    }
    
    
    /// Find departures
    ///
    /// - Parameter searchTerm: A station name to find
    /// - Parameter number: Number of departures to find
    /// - Parameter types: Types of transportation to find
    private mutating func findDepartures(searchTerm: String, number: Int, types: [Type]) {
        var newDepartures: [Departure]! = []
        
        var optimizedSearchTerm = searchTerm.replacingOccurrences(of: "Ä", with: "Ae").replacingOccurrences(of: "Ö", with: "Oe").replacingOccurrences(of: "Ü", with: "Ue").replacingOccurrences(of: "ä", with: "ae").replacingOccurrences(of: "ö", with: "oe").replacingOccurrences(of: "ü", with: "ue").replacingOccurrences(of: "ß", with: "ss")
        if optimizedSearchTerm.lowercased() == "ennigerloh" {
            optimizedSearchTerm = "Markt, Ennigerloh"
        } else if optimizedSearchTerm.lowercased() == "beckum" {
            optimizedSearchTerm = "Busbahnhof, Beckum"
        } else if optimizedSearchTerm.lowercased() == "hafencity" {
            optimizedSearchTerm = "Überseequartier, Hamburg"
        }
        let stationsPath = "https://reiseauskunft.bahn.de/bin/ajax-getstop.exe/dz?REQ0JourneyStopsS0A=1&REQ0JourneyStopsS0G=\(optimizedSearchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics) ?? optimizedSearchTerm.replacingOccurrences(of: " ", with: "%20"))"
        
        let stationsUrl = URL(string: stationsPath)!
        do {
            let stationsHtml = try String(contentsOf: stationsUrl, encoding: String.Encoding.ascii)
            
            if (stationsHtml.components(separatedBy: "extId\":\"").count > 0) {
                let stationsId = stationsHtml.components(separatedBy: "extId\":\"")[1].components(separatedBy: "\"")[0]
                
                let departuresPath = "https://mobile.bahn.de/bin/mobil/bhftafel.exe/dox?evaId=\(stationsId)&bt=dep&max=\(number)&rt=1&use_realtime_filter=1&disableEquivs=yes&p=\(encode(types))&start=yes"
                if let departuresUrl = URL(string: departuresPath) {
                    newDepartures = parse(departuresUrl)
                }
            }
        } catch {}
        
        if !newDepartures.isEmpty {
            departures = newDepartures
        } else if station == station.uppercased() {
            findDepartures(searchTerm: searchTerm + " Hbf", number: number, types: types)
        } else {
            station = searchTerm
        }
    }
    
    
    /// Find departures
    ///
    /// - Parameter coordinate: A coordinate from which to find the nearest station
    /// - Parameter number: Number of departures to find
    /// - Parameter types: Types of transportation to find
    private mutating func findDepartures(coordinate: CLLocationCoordinate2D, number: Int, types: [Type]) {
        let latitudeParts = coordinate.latitude.description.components(separatedBy: ".")
        let latitudePart1 = latitudeParts[0]
        let latitudePart2 = latitudeParts[1] + "000000"
        let latitude = Int(latitudePart1 + latitudePart2[...latitudePart2.index(latitudePart2.startIndex, offsetBy: 5)])!
        let longitudeParts = coordinate.longitude.description.components(separatedBy: ".")
        let longitudePart1 = longitudeParts[0]
        let longitudePart2 = longitudeParts[1] + "000000"
        let longitude = Int(longitudePart1 + longitudePart2[...longitudePart2.index(longitudePart2.startIndex, offsetBy: 5)])!
        
        var newDepartures: [Departure]! = []
        
        let nearbyStationUrlPath = "https://mobile.bahn.de/bin/mobil/query.exe/dox?performLocating=2&tpl=stopsnear&look_maxdist=1000&look_y=\(latitude)&look_x=\(longitude)"
        let nearbyStationUrl = URL(string: nearbyStationUrlPath)!
        do {
            let nearbyStationHtml = try String(contentsOf: nearbyStationUrl, encoding: String.Encoding.isoLatin1)
            
            let nearbyStationId = nearbyStationHtml.components(separatedBy: "class=\"uLine\" href=\"")[1].components(separatedBy: "!id=")[1].components(separatedBy: "!")[0]
            
            let departuresPath = "https://mobile.bahn.de/bin/mobil/bhftafel.exe/dox?evaId=\(nearbyStationId)&bt=dep&max=\(number)&rt=1&use_realtime_filter=1&disableEquivs=yes&p=\(encode(types))&start=yes"
            if let departuresUrl = URL(string: departuresPath) {
                newDepartures = parse(departuresUrl)
            }
        } catch {}
        
        if !newDepartures.isEmpty {
            departures = newDepartures
        }
    }
    
    
    /// Encode the types of transportation
    ///
    /// - Parameter types: Types of transportation
    /// - Returns: Types of transportation encoded in ones and zeros
    private func encode(_ types: [Type]) -> String {
        var products = ""
        
        if types.contains(.countryTrain) {
            products = products + "111"
        } else {
            products = products + "000"
        }
        
        if types.contains(.regionTrain) {
            products = products + "1"
        } else {
            products = products + "0"
        }
        
        if types.contains(.cityTrain) {
            products = products + "1"
        } else {
            products = products + "0"
        }
        
        if types.contains(.bus) {
            products = products + "1"
        } else {
            products = products + "0"
        }
        
        if types.contains(.underground) {
            products = products + "01"
        } else {
            products = products + "00"
        }
        
        if types.contains(.tram) {
            products = products + "10"
        } else {
            products = products + "00"
        }
        
        return products
    }
    
    
    /// Parse a website at an url to get the departures out of it
    ///
    /// - Parameter url: An url
    /// - Returns: Multiple departures
    private mutating func parse(_ url: URL) -> [Departure] {
        var newDepartures: [Departure]! = []
        
        do {
            let departuresHtml = try String(contentsOf: url, encoding: String.Encoding.isoLatin1)
            
            var departuresHtmlStation = departuresHtml.components(separatedBy: "<div class=\"inputtbl\">\n<div class=\"fline stdpadding\">\n<span class=\"bold\">\n")
            if departuresHtmlStation.count > 1 && departuresHtmlStation[1].components(separatedBy: " - Aktuell").count > 1 {
                station = departuresHtmlStation[1].components(separatedBy: " - Aktuell")[0]
            } else {
                return []
            }
            
            var departures = departuresHtml.components(separatedBy: "<div class=\"sqdetailsDep trow\">\n")
            
            if  departures[0].components(separatedBy: "<span class=\"bold\">\n").count > 0 {
                station = departures[0].components(separatedBy: "<span class=\"bold\">\n")[1].components(separatedBy: " - Aktuell")[0].replacingOccurrences(of: "&#196;", with: "Ä").replacingOccurrences(of: "&#214;", with: "Ö").replacingOccurrences(of: "&#220;", with: "Ü").replacingOccurrences(of: "&#223;", with: "ß").replacingOccurrences(of: "&#228;", with: "ä").replacingOccurrences(of: "&#246;", with: "ö").replacingOccurrences(of: "&#252;", with: "ü")
            }
            departures.remove(at: 0)
            
            for departure in departures {
                let departureHtml = departure.components(separatedBy: "<span class=\"bold\">")
                
                var line = departureHtml[1].components(separatedBy: "</span>")[0]
                let components = line.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
                line = components.filter { !$0.isEmpty }.joined(separator: " ")
                
                var direction = departureHtml[1].components(separatedBy: "</a>\n&gt;&gt;\n")[1].components(separatedBy: "\n")[0]
                direction = direction.replacingOccurrences(of: "&#196;", with: "Ä").replacingOccurrences(of: "&#214;", with: "Ö").replacingOccurrences(of: "&#220;", with: "Ü").replacingOccurrences(of: "&#223;", with: "ß").replacingOccurrences(of: "&#228;", with: "ä").replacingOccurrences(of: "&#246;", with: "ö").replacingOccurrences(of: "&#252;", with: "ü").replacingOccurrences(of: " (Bus+Tram)", with: "").replacingOccurrences(of: " (Airport)", with: "")
                
                var time = departureHtml[2].components(separatedBy: "</span>")[0]
                var delay = 0
                var delayTime = -60
                if departureHtml[2].contains(">+")  {
                    if let actualDelay = Int(departureHtml[2].components(separatedBy: ">+")[1].components(separatedBy: "</span>")[0]) {
                        if actualDelay > 0 {
                            delay = actualDelay
                        }
                        
                        delayTime = delayTime + (actualDelay * 60)
                    }
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                var date = dateFormatter.date(from: time)!
                date.addTimeInterval(TimeInterval(delayTime))
                time = dateFormatter.string(from: date)
                
                var platfrom = ""
                if departureHtml[2].contains("Gl. ")  {
                    platfrom = departureHtml[2].components(separatedBy: "Gl. ")[1].components(separatedBy: "</div>")[0].components(separatedBy: "</span>")[0].components(separatedBy: "<br />")[0].components(separatedBy: "<br/>")[0].components(separatedBy: ",")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    platfrom = platfrom.replacingOccurrences(of: "&#196;", with: "Ä").replacingOccurrences(of: "&#214;", with: "Ö").replacingOccurrences(of: "&#220;", with: "Ü").replacingOccurrences(of: "&#223;", with: "ß").replacingOccurrences(of: "&#228;", with: "ä").replacingOccurrences(of: "&#246;", with: "ö").replacingOccurrences(of: "&#252;", with: "ü").replacingOccurrences(of: " ", with: "")
                }
                
                var type = Type.regionTrain
                if (Type.bus.matches(description: line)) {
                    type = .bus
                } else if (Type.tram.matches(description: line)) {
                    line = line.replacingOccurrences(of: "STR ", with: "Tram ")
                    type = .tram
                } else if (Type.underground.matches(description: line)) {
                    type = .underground
                } else if (Type.cityTrain.matches(description: line)) {
                    type = .cityTrain
                } else if (Type.countryTrain.matches(description: line)) {
                    type = .countryTrain
                }
                
                if !departureHtml[2].contains("Fahrt fällt aus") {
                    newDepartures.append(Departure(of: line, with: type, to: direction, at: time, with: delay, from: platfrom))
                }
            }
        } catch {}
        
        return newDepartures
    }
}
