# NavigationAppKit

This swift package helps dealing with navigation apps on iOS devices.
It provides easy access to open a navigation app via URL scheme.
Apple Maps is also supported by internal MapKit api.


Here is a simple example how to use this package:
```Swift
/// First check which supported navigation apps are installed
let installedNavigationApps = NavigationApp.installedNavigationApps
/// or check if a certian one is installed:
guard NavigationApp.canOpen(.organicMaps) else { return }

/// If the wanted app is installed, open a destination location in it
let destination = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
let options = NavigationApp.Options(location: destination,
                                   navigationMode: .showOnMap)
try NavigationApp.organicMaps.buildFullUrl(with: options)

/// Route to a destination. Not set startLocation usually uses the current user position
let destination = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
let options = NavigationApp.Options(location: destination,
                                    navigationMode: .route(directionsMode: .walking, startLocation: nil))
```

It is also a good idea to check the tests of this package for the API usage.


## Restrictions
                                                
On Apple plattforms it is required to have the following section in the Info.plist file in order to be able to check if an app is installed/open it:
```
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>comgooglemaps</string>
    <string>om</string>
    <string>mapswithme</string>
    <string>waze</string>
    <string>com.sygic.aura</string>
    <string>navigon</string>
    <string>here-location</string>
    <string>here-route</string>
</array>
```

*HERE WeGo* uses different url schemes for showing a point on the map and for navigation. This is why it is listed with two different url schemes in the `Info.plist` file as well.


To check if an app itself supports opening it with an url scheme, you can check the *Info.plist* file within the app container. 
Look for the key *CFBundleURLSchemes* inside *CFBundleURLTypes*.
