


import SwiftUI

struct ContentView: View {
    @StateObject private var reminderListViewModel = ReminderListViewModel()
    @StateObject private var mapViewModel: MapViewModel

    init() {
        let reminderListViewModel = ReminderListViewModel()
        _mapViewModel = StateObject(wrappedValue: MapViewModel(reminderListViewModel: reminderListViewModel))
        _reminderListViewModel = StateObject(wrappedValue: reminderListViewModel)
    }

    var body: some View {
        TabView {
            MapView(reminderListViewModel: reminderListViewModel, mapViewModel: mapViewModel)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            ReminderListView(viewModel: reminderListViewModel, mapViewModel: mapViewModel)
                .tabItem {
                    Label("Reminders", systemImage: "list.bullet")
                }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



