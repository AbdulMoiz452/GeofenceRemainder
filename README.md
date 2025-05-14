# Create README.md
cat > README.md << 'EOF'
# GeofenceReminders

GeofenceReminders is an iOS app that allows users to set location-based reminders using geofencing. Users can select locations on a map, define a geofence radius, add notes, and receive notifications when entering or exiting the geofenced area. The app features a tabbed interface with a map view for location selection and a list view for managing reminders, built with SwiftUI, CoreLocation, MapKit, Core Data, and UserNotifications.

## Features

- **Map-Based Location Selection**: Browse and select points of interest (POIs) on a map, fetched from the Overpass API.
- **Geofence Monitoring**: Set geofences with customizable radii and receive notifications on entry/exit.
- **Reminder Management**: View, edit, and delete reminders in a list view, with persistent storage using Core Data.
- **Local Notifications**: Alerts for geofence events and test notifications for debugging.
- **Offline Support**: Displays an offline mode indicator when network requests fail.
- **Debugging Tools**: In-app logs for authorization status, geofence events, and notifications, with buttons to request permissions, test notifications, and clear geofences.

## Approach

I break the application into smaller parts for simplicity. First I created a simple app in which I gave a hardcoded location, wrote functions to check whether they work fine if the user enters or exits the saved radius and coordinates. I added a simple button to test the notifications in a simpler manner. After testing notifications I tried to integrate the functions with my notifications such that notifications trigger when the user enters or exits the saved location. After doing that I then moved towards developing the application as a separate project which uses CoreLocation, MapKit and CoreData along with views that are required by our required application. I then tried to integrate my previous notifications triggering code and location manager functions into the main application.

The app is designed to provide a seamless user experience for location-based reminders, leveraging Apple’s native frameworks for robust functionality:

### Architecture

- **SwiftUI**: Used for the UI, with a tabbed interface (ContentView) containing MapView (for location selection) and ReminderListView (for reminder management).
- **MVVM Pattern**: View models (MapViewModel, ReminderListViewModel) manage business logic, separating UI from data handling.
- **Core Data**: Persists reminders (GeofenceReminder entities) for reliable storage and retrieval.
- **CoreLocation**: Handles geofence monitoring and location authorization, with robust logging for debugging.
- **MapKit**: Displays an interactive map for selecting POIs and visualizing geofences.
- **UserNotifications**: Schedules local notifications for geofence entry/exit events and provides a test notification feature.
- **Network Service**: Fetches POIs from the Overpass API using Combine for asynchronous data handling.

### Key Components

- **MapViewModel**: Manages location fetching, geofence monitoring, and notifications. Integrates authorization handling, logging, and test features inspired by a simplified test app (LocationViewModel).
- **ReminderListViewModel**: Handles Core Data operations for reminders, ensuring real-time updates across views.
- **ContentView**: Coordinates the tabbed UI, sharing view models for consistent state management.
- **Debugging Features**: Added buttons to request location authorization, test notifications, and clear geofences, with a log display in both tabs for real-time feedback.

### Integration Strategy

- Enhanced MapViewModel to include robust geofence monitoring and logging from a test app, ensuring compatibility with existing map and reminder features.
- Added UI controls (buttons and logs) to MapView and ReminderListView for debugging without disrupting core functionality.
- Ensured the Info.plist supports location permissions and background modes for geofencing.

## Third-Party Libraries

No third-party libraries are used. The app relies entirely on Apple’s native frameworks:
- **SwiftUI**: For the user interface.
- **CoreLocation**: For geofencing and location services.
- **MapKit**: For map display and interaction.
- **Core Data**: For persistent storage of reminders.
- **UserNotifications**: For local notifications.
- **Combine**: For handling asynchronous network requests.

This approach minimizes dependencies, ensuring compatibility and reducing maintenance overhead.

## Setup Steps

Follow these steps to set up and run the GeofenceReminders app on macOS using Xcode.

### Prerequisites

- **macOS**: Ventura 13.0 or later.
- **Xcode**: Version 16 or later.
- **iOS Device or Simulator**: iOS 18 or later recommended.
- **Apple Developer Account**: Required for signing the app (optional for simulator testing).

### Verify Info.plist

Ensure Info.plist includes:
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to monitor geofences in the background.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to set up geofences.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
</array>
