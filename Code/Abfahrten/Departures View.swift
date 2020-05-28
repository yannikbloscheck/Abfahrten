import Foundation
import SwiftUI


/// Main view for all departures
///
/// - Copyright: © Yannik Bloscheck - All rights reserved
/// - Since: 2020-05-28
struct DeparturesView: View {
	/// The color scheme
	@Environment(\.colorScheme) var colorScheme
	
	
	/// A timer for refreshing the departures every minute
	var timer = Timer.publish(every: 60, on: .main, in: .default).autoconnect()
	
	/// The station manager
	@ObservedObject var stationManager: StationManager
	
	
	/// Are the search terms currently getting edited?
	@State private var isEditing: Bool = false
	
	
	/// Is the waiting spinner currently spinning?
	@State private var isSpinning: Bool = false
	
	
	/// The search terms
	@State private var searchTerms = ""
	
	
	/// The actual view
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				if self.isEditing {
					Spacer()
				} else if self.stationManager.hasNewStation {
					VStack(alignment: .center) {
						   Spacer()
						   Image(systemName: "slowmo")
							.font(.title)
							.opacity(0.2)
							.rotationEffect(.degrees(self.isSpinning ? 360 : 0))
							.animation(Animation.linear(duration: 1.6).repeatForever(autoreverses: false))
							.onAppear {
								self.isSpinning.toggle()
							}
						    Spacer()
					}
					.padding([.top], geometry.safeAreaInsets.top)
				} else if self.stationManager.station == nil {
					VStack(alignment: .center) {
						   Spacer()
						   Text("NO_STATION")
							   .opacity(0.2)
						   Spacer()
					}
					.padding([.top], geometry.safeAreaInsets.top)
				} else if !self.stationManager.station!.departures.isEmpty {
					ScrollView(.vertical, showsIndicators: false) {
						VStack(alignment: .center) {
							ForEach(self.stationManager.station!.departures, id: \.self) { departure in
								DepartureView(departure: departure)
									.frame(minWidth: 200, maxWidth: .infinity, minHeight: 44, idealHeight: 48, maxHeight: 88, alignment: .top)
							}
						}
						.padding([.top], geometry.safeAreaInsets.top + 57)
					}
			   } else {
					VStack(alignment: .center) {
						   Spacer()
						   Text("NO_DEPARTURES")
							   .opacity(0.2)
						   Spacer()
					}
					.padding([.top], geometry.safeAreaInsets.top)
			    }
				VStack {
					VStack {
						HStack(alignment: .center, spacing: 0) {
							Image(systemName: "magnifyingglass")
								.font(.caption)
								.foregroundColor(Color.primary.opacity(0.3))
								.padding(.leading, 10)
							TextField((self.stationManager.hasNewStation ? NSLocalizedString("SEARCHING", comment: "Searching...") : (self.isEditing ? NSLocalizedString("NAME", comment: "Name") : self.stationManager.station?.name ?? NSLocalizedString("SEARCH", comment: "Search"))), text: self.$searchTerms, onEditingChanged: { isEditing in
								self.isEditing = isEditing
							}, onCommit: {
								self.isEditing = false
								self.stationManager.hasNewStation = true
								self.stationManager.refreshStation(with: self.searchTerms){
									if let station = self.stationManager.station {
										self.searchTerms = station.name
									}
								}
							})
								.padding(.top, 6)
								.padding(.bottom, 4)
								.padding([.leading,.trailing], 6)
							if self.isEditing {
								Button(action: {
									UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
									self.isEditing = false
									self.stationManager.hasNewStation = true
									self.searchTerms = ""
									self.stationManager.refreshStation(with: self.searchTerms){}
								}) {
									Image(systemName: "xmark.circle.fill").font(.body)
								}
								.padding([.trailing], 8)
								.foregroundColor(Color.primary)
							}
						}
						.background(Color("Dark Background Color"))
						.cornerRadius(6)
						.padding([.top], geometry.safeAreaInsets.top)
						.padding(.all, 8)
					}
					.background(Color("Light Background Color"))
					.clipped()
					.shadow(color: Color.black.opacity(self.colorScheme == .dark ? 0.3 : 0.2), radius: (self.colorScheme == .dark ? 4 : 2), x: 0, y: (self.colorScheme == .dark ? 2 : 1))
					Spacer()
				}
			}
			.edgesIgnoringSafeArea(.top)
			.accentColor(Color("Tint Color"))
			.background(Color("Dark Background Color"))
		}.onReceive(timer) { (_) in
			if !self.isEditing, !self.stationManager.hasNewStation {
				self.stationManager.refreshStation(with: self.searchTerms){
				}
			}
		}
    }
}



// MARK: -

/// Provides helpful previews
struct DeparturesView_Previews: PreviewProvider {
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
