import Foundation
import SwiftUI


/// View for a single departure
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2020-05-28
struct DepartureView: View {
	// MARK: Properties
	
	/// The color scheme
	@Environment(\.colorScheme) var colorScheme
	
	
	
	/// The departure
	var departure: Departure
	
	
	
	/// The formatted version of the departure time
	private var formattedTime: String {
		get {
			let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
			return timeFormatter.string(from: departure.date)
		}
	}
	
	
	
	/// The formatted version of the departure platform and/or a possible delay
	private var formattedPlatformAndDelay: String? {
		get {
			if let delay = departure.delay, delay > 60 {
                if let platform = departure.platform, !platform.isEmpty {
					return NSLocalizedString("PLATFORM", comment: "Platform") + " \(platform ), +\(delay/60)"
                } else {
                    return "+\(delay/60)"
                }
            } else if let platform = departure.platform, !platform.isEmpty {
				return NSLocalizedString("PLATFORM", comment: "Platform") + " \(platform)"
			} else {
				return nil
			}
		}
	}
	
	
	
	/// The actual view
	var body: some View {
		HStack {
			Image(departure.type.symbol)
			.renderingMode(.template)
			.resizable()
			.foregroundColor(Color.accentColor)
			.aspectRatio(contentMode: .fit)
			.layoutPriority(1)
			
			VStack(alignment: .leading) {
				Text(departure.line)
				.font(.body)
				.fontWeight(.bold)
				.foregroundColor(Color.accentColor)
				
				Text(departure.direction)
				.font(.caption)
				.fontWeight(.bold)
				.foregroundColor(Color.accentColor)
			}
			.layoutPriority(0)
			
			Spacer()
			
			VStack(alignment: .trailing) {
				Text(formattedTime)
				.font(.body)
				.fontWeight(.bold)
				.foregroundColor((departure.delay ?? 0) > 60 ? Color("Alert Color") :Color.accentColor)
				
				if formattedPlatformAndDelay != nil {
					Text(formattedPlatformAndDelay ?? "")
					.font(.caption)
					.fontWeight(.bold)
					.foregroundColor((departure.delay ?? 0) > 60 ? Color("Alert Color") :Color.accentColor)
				}
			}
			.layoutPriority(1)
			.padding(.trailing, 8)
		}
		.background(Color("Light Background Color"))
		.shadow(color: Color.black.opacity(colorScheme == .dark ? 0.8 : 0.1), radius: (colorScheme == .dark ? 4 : 2), x: 0, y: (colorScheme == .dark ? 2 : 1))
    }
}




// MARK: -

/// Provides helpful previews
struct DeparturePreviews: PreviewProvider {
	// MARK: Properties
	
	/// Helpful previews
    static var previews: some View {
		Group {
			DepartureView(departure: Departure(of: "Train 1", with: .countryTrain, to: "Final Destination", at: Date(), with: 0, from: "A"))
			.accentColor(Color("Accent Color"))
			.previewLayout(.fixed(width: 320, height: 44))
			.environment(\.colorScheme, .light)
			
			DepartureView(departure: Departure(of: "Train 2", with: .countryTrain, to: "Final Destination", at: Date(), with: 3600, from: "B"))
			.accentColor(Color("Accent Color"))
			.previewLayout(.fixed(width: 320, height: 44))
			.environment(\.colorScheme, .light)
			
			DepartureView(departure: Departure(of: "Tram 3", with: .tram, to: "Final Destination", at: Date(), with: 7200, from: "C"))
			.accentColor(Color("Accent Color"))
			.previewLayout(.fixed(width: 320, height: 44))
			.environment(\.colorScheme, .dark)
			
			DepartureView(departure: Departure(of: "Tram 4", with: .tram, to: "Final Destination", at: Date()))
			.accentColor(Color("Accent Color"))
			.previewLayout(.fixed(width: 320, height: 44))
			.environment(\.colorScheme, .dark)
		}
    }
}
