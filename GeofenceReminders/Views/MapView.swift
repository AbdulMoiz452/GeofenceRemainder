


import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var reminderListViewModel: ReminderListViewModel
    @ObservedObject var mapViewModel: MapViewModel
    @State private var selectedLocation: Location?

    var body: some View {
        VStack {
            ZStack {
                Map(coordinateRegion: $mapViewModel.region, annotationItems: mapViewModel.locations) { location in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.red)
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                }
                .ignoresSafeArea()

                if mapViewModel.isOffline {
                    VStack {
                        Text("Offline Mode")
                            .padding()
                            .background(Color.yellow)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Spacer()
                    }
                }
            }

            // Control buttons
            VStack {
                Button("Request Location Authorization") {
                    mapViewModel.requestAuthorization()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Test Notification") {
                    mapViewModel.testNotification()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button("Clear Geofences") {
                    mapViewModel.clearGeofences()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()

            // Log display
            List(mapViewModel.logMessages, id: \.self) { message in
                Text(message)
                    .font(.caption)
            }
            .frame(height: 150)
        }
        .sheet(item: $selectedLocation) { location in
            ReminderDetailView(location: location, viewModel: mapViewModel)
        }
        .alert(isPresented: $mapViewModel.showPermissionAlert) {
            Alert(
                title: Text("Location Permission Required"),
                message: Text("Please enable location services to use geofencing"),
                primaryButton: .default(Text("Open Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(reminderListViewModel: ReminderListViewModel(), mapViewModel: MapViewModel(reminderListViewModel: ReminderListViewModel()))
    }
}



