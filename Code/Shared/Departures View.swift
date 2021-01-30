import Foundation
import SwiftUI


/// Main view for all departures
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2020-05-28
struct DeparturesView: View {
	// MARK: Properties
	
	/// The color scheme
	@Environment(\.colorScheme) var colorScheme
	
	
	
	/// A timer for refreshing the departures every minute
	var timer = Timer.publish(every: 60, on: .main, in: .default).autoconnect()
	
	
	
	/// The station manager
	@ObservedObject var stationManager: StationManager
	
	
	
	/// Are the search terms currently getting edited?
	@State private var isEditing: Bool = false
	
	
	
	/// The search terms
	@State private var searchTerms = ""
	
	
	
	/// The view for the top bar
	var bar: some View {
		VStack {
			HStack(alignment: .center, spacing: 0) {
				Image(systemName: "magnifyingglass")
				.font(.caption)
				.foregroundColor(Color.primary.opacity(0.25))
				.padding(.leading, 10)
				
				TextField((self.stationManager.hasNewStation ? NSLocalizedString("SEARCHING", comment: "Searching...") : (self.isEditing ? NSLocalizedString("NAME", comment: "Name") : self.stationManager.station?.name ?? NSLocalizedString("SEARCH", comment: "Search"))), text: self.$searchTerms, onEditingChanged: { isEditing in
					if isEditing {
						self.isEditing = isEditing
					}
				}, onCommit: {
					self.stationManager.hasNewStation = true
					self.stationManager.refreshStation(with: self.searchTerms) {
						if !self.searchTerms.isEmpty , let station = self.stationManager.station {
							self.searchTerms = station.name
						} else {
							self.searchTerms = ""
						}
						
						self.isEditing = false
						
						#if os(macOS)
						NSApplication.shared.keyWindow?.makeFirstResponder(nil)
						#else
						UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
						#endif
					}
				})
				.textFieldStyle(PlainTextFieldStyle())
				.padding(.top, 6)
				.padding(.bottom, 4)
				.padding([.leading,.trailing], 6)
				
				if self.isEditing, !self.stationManager.hasNewStation {
					Button(action: {
						self.isEditing = false
						self.stationManager.hasNewStation = true
						self.searchTerms = ""
						self.stationManager.refreshStation(with: self.searchTerms){}
						
						#if os(macOS)
						NSApplication.shared.keyWindow?.makeFirstResponder(nil)
						#else
						UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
						#endif
					}) {
						Image(systemName: "xmark.circle.fill").font(.body)
					}
					.buttonStyle(BorderlessButtonStyle())
					.padding([.trailing], 8)
					.foregroundColor(Color.primary)
				}
			}
			.background(Color("Dark Background Color"))
			.cornerRadius(6)
			.padding(.top, 4)
			.padding([.bottom,.leading,.trailing], 8)
		}
	}
	
	
	
	/// The actual view
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Spacer()
				.background(Color("Dark Background Color"))
				.edgesIgnoringSafeArea(.bottom)
				
				VStack(spacing: 0) {
					bar
					.clipped()
					.hidden()
					
					if self.stationManager.hasNewStation {
						VStack(alignment: .center) {
							Spacer()
							
							ProgressView().progressViewStyle(CircularProgressViewStyle())
							
							Spacer()
						}
					} else if self.isEditing {
						Spacer()
					} else if self.stationManager.station == nil {
						VStack(alignment: .center) {
							Spacer()
							
							Text("NO_STATION")
							.opacity(0.2)
							
							Spacer()
						}
					} else if !self.stationManager.station!.departures.isEmpty {
						ScrollView(.vertical, showsIndicators: true) {
							LazyVStack(alignment: .center) {
								Spacer()
								.frame(minHeight: 12, maxHeight: 12)
								
								ForEach(self.stationManager.station!.departures, id: \.self) { departure in
									DepartureView(departure: departure)
									.frame(minWidth: 200, maxWidth: .infinity, minHeight: 44, idealHeight: 48, maxHeight: 88, alignment: .top)
								}
							}
						}
				   } else {
						VStack(alignment: .center) {
						   Spacer()
						
						   Text("NO_DEPARTURES")
							.opacity(0.2)
						
						   Spacer()
						}
					}
				}
				
				VStack(spacing: 0) {
					bar
					.padding([.top], geometry.safeAreaInsets.top)
					.background(Color("Light Background Color"))
					.clipped()
					.shadow(color: Color.black.opacity(self.colorScheme == .dark ? 0.9 : 0.2), radius: (self.colorScheme == .dark ? 4 : 2), x: 0, y: (self.colorScheme == .dark ? 2 : 1))
					
					Spacer()
				}
				.edgesIgnoringSafeArea(.top)
			}
			.accentColor(Color("Accent Color"))
			.onReceive(timer) { (_) in
				if !self.isEditing, !self.stationManager.hasNewStation {
					self.stationManager.refreshStation(with: self.searchTerms){
					}
				}
			}
		}
    }
}




// MARK: -

/// Provides helpful previews
struct DeparturesPreviews: PreviewProvider {
	// MARK: Properties
	
	/// Example station manager for previews
	static private var stationManager: StationManager {
		get {
			let stationManager = StationManager()
			stationManager.hasNewStation = false
			stationManager.station = Station(name: "Central Station", date: Date(), departures: [Departure(of: "Train 1", with: .countryTrain, to: "Final Destination", at: Date(), with: 0, from: "A"),Departure(of: "Train 2", with: .countryTrain, to: "Final Destination", at: Date(), with: 3600, from: "B"), Departure(of: "Tram 3", with: .tram, to: "Final Destination", at: Date(), with: 7200, from: "C"), Departure(of: "Tram 4", with: .tram, to: "Final Destination", at: Date())])
			return stationManager
		}
	}
	
	
	
	/// Helpful previews
	static var previews: some View {
		Group{
			DeparturesView(stationManager: stationManager)
			.environment(\.colorScheme, .light)
			
			DeparturesView(stationManager: stationManager)
			.environment(\.colorScheme, .dark)
		}
    }
}
