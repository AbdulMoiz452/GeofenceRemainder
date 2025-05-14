

import SwiftUI

struct ReminderDetailView: View {
    let location: Location
    @ObservedObject var viewModel: MapViewModel
    @State private var radius: Double = 500
    @State private var note: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Location")) {
                    Text(location.name)
                    Text("Category: \(location.category)")
                }
                
                Section(header: Text("Geofence Radius")) {
                    RadiusSelectorView(radius: $radius)
                        .frame(height: 200)
                    Text("Radius: \(Int(radius))m")
                }
                
                Section(header: Text("Note")) {
                    TextField("Add a note", text: $note)
                }
            }
            .navigationTitle("Set Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveReminder(location: location, radius: radius, note: note)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ReminderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderDetailView(
            location: Location(id: "1", name: "Central Park", latitude: 40.785091, longitude: -73.968285, category: "Park"),
            viewModel: MapViewModel(reminderListViewModel: ReminderListViewModel())
        )
    }
}
