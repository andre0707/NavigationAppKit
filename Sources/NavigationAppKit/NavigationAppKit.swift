//
//  NavigationApp.swift
//
//
//  Created by Andre Albach on 27.08.23.
//

import CoreLocation
import MapKit
import UIKit


/// Navigation apps which can be opened via url schme
///
/// On Apple plattforms it is required to have the following section in the Info.plist file in order to be able to check if an app is installed:
/// <key>LSApplicationQueriesSchemes</key>
/// <array>
///     <string>comgooglemaps</string>
///     <string>om</string>
///     <string>mapswithme</string>
///     <string>waze</string>
///     <string>com.sygic.aura</string>
///     <string>navigon</string>
///     <string>here-location</string>
///     <string>here-route</string>
/// </array>
///
/// To get a list of all installed and supported navigation apps on the users device, use:
/// ```
/// let installedNavigationApps = NavigationApp.installedNavigationApps
/// ```
///
/// Open a navigation app to show coordinates like so:
/// ```
/// let location = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
/// let options = NavigationApp.Options(location: location,
///                                    navigationMode: .showOnMap,
///                                    locationName: nil)
/// try NavigationApp.organicMaps.buildFullUrl(with: options)
/// ```
///
/// Fill the options struct with what you need. It also supports routing.
///
/// Not every navigation app supports all functionalities. Errors will be thrown, if something is not supported.
/// Make sure to use the correct options if an error is thrown.
///
public enum NavigationApp: Int, CaseIterable, CustomStringConvertible, Identifiable {
    case appleMaps = 0
    case googleMaps // https://developers.google.com/maps/documentation/ios/urlscheme
    case organicMaps // https://omaps.app/api
    case mapsMe // https://github.com/mapsme/api-ios
    case waze // https://developers.google.com/waze/deeplinks?hl=en
    case sygic // https://www.sygic.com/de/developers/professional-navigation-sdk/ios/custom-url
    case hereWeGo //https://stackoverflow.com/questions/13514532/launch-nokia-here-maps-ios-via-api
    case navigon
    
    /// Conformence to `CustomStringConvertible` protocol.
    public var description: String { name }
    /// Conformence to `Identifiable` protocol.
    public var id: Int { rawValue }
    
    /// The name of the navigation app
    public var name: String {
        switch self {
        case .appleMaps: return String(localized: "Maps")
        case .googleMaps: return "Google Maps"
        case .organicMaps: return "Organic Maps"
        case .mapsMe: return "maps.me"
        case .waze: return "Waze"
        case .sygic: return "Sygic"
        case .hereWeGo: return "HERE WeGo"
        case .navigon: return "Navigon"
        }
    }
    
    /// The url scheme of the app
    public func urlScheme(for navigationMode: NavigationMode) -> String {
        switch self {
        case .appleMaps: return "https://maps.apple.com/" // This works, but on Apple devices, we will open the Maps app via internal API
        case .googleMaps: return "comgooglemaps://"
        case .organicMaps: return "om://"
        case .mapsMe: return "mapswithme://"
        case .waze: return "waze://"
        case .sygic: return "com.sygic.aura://"
        case .hereWeGo:
            switch navigationMode {
            case .showOnMap: return "here-location://"
            case .route(_, let startLocation):
                if let startLocation {
                    /// If the start location is given, it will be set as part of the url scheme
                    return "here-route://\(startLocation.defaultParameterFormatted)/"
                } else {
                    /// If the start location is not given, the user location will be set as part of the url scheme
                    return "here-route://mylocation/"
                }
            }
        case .navigon: return "navigon://"
        }
    }
    
    /// Indicator, if this navigation app supports a start location when `NavigationMode.route` is picked
    public var supportsStartLocationInRoute: Bool {
        switch self {
        case .googleMaps,
                .organicMaps,
                .hereWeGo:
            return true
        default:
            return false
        }
    }
    
    /// Indicator, if this navigation app supports routing
    public var supportsRouting: Bool {
        switch self {
        case .mapsMe:
            return false
        default:
            return true
        }
    }
    
    /// This function checks if the passed in `app` can be opened or not.
    /// If the app is not installed, it can not be opened
    /// - Parameter app: The app which should be checked
    /// - Returns: Indicator if `app` can be opened or not
    public static func canOpen(_ app: NavigationApp) -> Bool {
        if app == .appleMaps { return true }
        
        guard let url = URL(string: app.urlScheme(for: .showOnMap)) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// Indicator, if the app `self` can be opened or not
    public var canOpen: Bool { NavigationApp.canOpen(self) }
    
    /// A list of all the installed navigation apps on the users device
    public static var installedNavigationApps: [NavigationApp] { NavigationApp.allCases.filter { $0.canOpen } }
    
    /// Will build the full url to open the navigation app with the passed in `options`
    /// - Parameter options: The options which should be used to build the navigation app url
    /// - Returns: The full url to the navigation app, if available.
    /// It can throw if `options` are not valid for the picked navigation app
    public func buildFullUrl(with options: Options) throws -> URL? {
        switch self {
        case .appleMaps:
            return nil //Will be handled with internal API, so a url is not needed here. But could look like this: URL(string: "\(urlScheme(for: options.navigationMode))?q=\(options.location.latitude.stringFormatted),\(options.location.longitude.stringFormatted)")
            
        case .googleMaps:
            let urlScheme = urlScheme(for: options.navigationMode)
            
            switch options.navigationMode {
            case .showOnMap:
                return URL(string: "\(urlScheme)?q=\(options.location.defaultParameterFormatted)")
                
            case .route(directionsMode: let directionsMode, startLocation: let startLocation):
                var parameters: [Parameter] = []
                if let directionsMode = directionsMode?.directionModeKey(for: .googleMaps) {
                    parameters.append(Parameter(key: "directionsmode", value: directionsMode))
                }
                if let startLocation = startLocation {
                    parameters.append(Parameter(key: "saddr", value: startLocation.defaultParameterFormatted))
                }
                parameters.append(Parameter(key: "daddr", value: options.location.defaultParameterFormatted))
                
                return URL(string: "\(urlScheme)?\(parameters.createParameterString())")
            }
            
        case .organicMaps:
            let urlScheme = urlScheme(for: options.navigationMode)
            var parameters: [Parameter] = [] // organic maps requires a strict order in the parameters. See API link
            
            switch options.navigationMode {
            case .showOnMap:
                parameters.append(Parameter(key: "v", value: "1"))
                parameters.append(Parameter(key: "ll", value: options.location.defaultParameterFormatted))
                if let locationName = options.locationName {
                    parameters.append(Parameter(key: "n", value: locationName))
                }
                
                return URL(string: "\(urlScheme)map?\(parameters.createParameterString())")
                
            case .route(directionsMode: let directionsMode, startLocation: let startLocation):
                guard let startLocation = startLocation else { throw Errors.requiresStartLocation }
                parameters.append(Parameter(key: "sll", value: startLocation.defaultParameterFormatted))
                parameters.append(Parameter(key: "saddr", value: "Start"))
                parameters.append(Parameter(key: "dll", value: options.location.defaultParameterFormatted))
                parameters.append(Parameter(key: "daddr", value: options.locationName ?? "End"))
                parameters.append(Parameter(key: "type", value: (directionsMode ?? .driving).directionModeKey(for: .organicMaps)!))
                
                return URL(string: "\(urlScheme)route?\(parameters.createParameterString())")
            }
            
        case .mapsMe:
            let urlScheme = urlScheme(for: options.navigationMode)
            var parameters: [Parameter] = [] // organic maps requires a strict order in the parameters. See API link
            
            switch options.navigationMode {
            case .showOnMap:
                parameters.append(Parameter(key: "v", value: "1"))
                parameters.append(Parameter(key: "ll", value: options.location.defaultParameterFormatted))
                if let locationName = options.locationName {
                    parameters.append(Parameter(key: "n", value: locationName))
                }
                
                return URL(string: "\(urlScheme)map?\(parameters.createParameterString())")
                
            
            case .route(directionsMode: _, startLocation: _):
                throw Errors.doesNotSupportRouting
                // This is how it should work, however as of today (2023-08-27) routing urls do not work with maps.me
//            case .route(directionsMode: let directionsMode, startLocation: let startLocation):
//                guard let startLocation = startLocation else { throw Errors.requiresStartLocation }
//                parameters.append(Parameter(key: "sll", value: startLocation.defaultParameterFormatted))
//                parameters.append(Parameter(key: "saddr", value: "Start"))
//                parameters.append(Parameter(key: "dll", value: options.location.defaultParameterFormatted))
//                parameters.append(Parameter(key: "daddr", value: options.locationName ?? "End"))
//                parameters.append(Parameter(key: "type", value: (directionsMode ?? .driving).directionModeKey(for: .organicMaps)!))
//                
//                return URL(string: "\(urlScheme)route?\(parameters.createParameterString())")
            }
            
        case .waze:
            let urlScheme = urlScheme(for: options.navigationMode)
            
            switch options.navigationMode {
            case .showOnMap:
                return URL(string: "\(urlScheme)?ll=\(options.location.defaultParameterFormatted)")
                
            case .route(directionsMode: let directionsMode, startLocation: let startLocation):
                guard directionsMode == nil || directionsMode == .driving else { throw Errors.unsupportedDirectionsMode }
                guard startLocation == nil else { throw Errors.doesNotSupportStartLocation }
                
                let parameters: [Parameter] = [
                    Parameter(key: "ll", value: options.location.defaultParameterFormatted),
                    Parameter(key: "navigate", value: "yes")
                ]
                
                return URL(string: "\(urlScheme)?\(parameters.createParameterString())")
            }
            
        case .sygic:
            // %7C is url encoding for |
            let urlScheme = urlScheme(for: options.navigationMode)
            
            switch options.navigationMode {
            case .showOnMap:
                if let locationName = options.locationName {
                    return URL(string: "\(urlScheme)coordinate%7C\(options.location.longitude.stringFormatted)%7C\(options.location.latitude.stringFormatted)%7C\(locationName)%7Cshow")
                } else {
                    return URL(string: "\(urlScheme)coordinate%7C\(options.location.longitude.stringFormatted)%7C\(options.location.latitude.stringFormatted)%7Cshow")
                }
                
            case .route(directionsMode: let directionsMode, startLocation: let startLocation):
                guard startLocation == nil else { throw Errors.doesNotSupportStartLocation }
                guard let directionsModeKey = (directionsMode ?? .driving).directionModeKey(for: .sygic) else { throw Errors.unsupportedDirectionsMode }
                
                if let locationName = options.locationName {
                    return URL(string: "\(urlScheme)coordinate%7C\(options.location.longitude.stringFormatted)%7C\(options.location.latitude.stringFormatted)%7C\(locationName)%7C\(directionsModeKey)")
                } else {
                    return URL(string: "\(urlScheme)coordinate%7C\(options.location.longitude.stringFormatted)%7C\(options.location.latitude.stringFormatted)%7C\(directionsModeKey)")
                }
            }
            
        case .hereWeGo:
            let urlScheme = urlScheme(for: options.navigationMode)
            
            switch options.navigationMode {
            case .showOnMap:
                if let locationName = options.locationName {
                    return URL(string: "\(urlScheme)\(options.location.defaultParameterFormatted),\(locationName)")
                } else {
                    return URL(string: "\(urlScheme)\(options.location.defaultParameterFormatted)")
                }
                
            case .route(directionsMode: let directionsMode, startLocation: _):
                guard let directionsModeValue = (directionsMode ?? .driving).directionModeKey(for: .hereWeGo) else { throw Errors.unsupportedDirectionsMode }
                let parameters = [Parameter(key: "m", value: directionsModeValue)]
                
                if let locationName = options.locationName {
                    return URL(string: "\(urlScheme)\(options.location.defaultParameterFormatted),\(locationName)?\(parameters.createParameterString())")
                } else {
                    return URL(string: "\(urlScheme)\(options.location.defaultParameterFormatted)?\(parameters.createParameterString())")
                }
            }
            
        case .navigon:
                // %7C is url encoding for |
            return URL(string: "\(urlScheme(for: options.navigationMode))%7C%7C%7C%7C%7C%7C\(options.location.latitude.stringFormatted)%7C\(options.location.longitude.stringFormatted)")
        }
    }
    
    /// Will open the navigation app with the passed in `options` if possible. Can throw an error if something does not match.
    /// - Parameter options: The options with which the navigation app should be opened
    public func open(with options: Options) throws {
        if self == .appleMaps {
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: options.location))
            mapItem.name = options.locationName
            
            var launchOptions: [String : Any] = [:]
            switch options.navigationMode {
            case .showOnMap:
                break
            case .route(let directionsMode, let startLocation):
                guard startLocation == nil else { throw Errors.doesNotSupportStartLocation }
                
                switch directionsMode {
                case .none:
                    break
                case .some(let directionsMode):
                    if let appleMapsKey = directionsMode.directionModeKey(for: .appleMaps) {
                        launchOptions[MKLaunchOptionsDirectionsModeKey] = appleMapsKey
                    }
                    /// Other supported keys:
                    //MKLaunchOptionsCameraKey
                    //MKLaunchOptionsMapCenterKey
                    //MKLaunchOptionsMapSpanKey
                    //MKLaunchOptionsMapTypeKey
                    //MKLaunchOptionsShowsTrafficKey
                }
            }
            
            guard mapItem.openInMaps(launchOptions: launchOptions) else { throw Errors.mapKitAPI }
            return
        }
        
        guard let url = try buildFullUrl(with: options) else { throw Errors.invalidAppUrl }
        
        UIApplication.shared.open(url)
    }
}


// MARK: - NavigationApp.Options

extension NavigationApp {
    
    /// A struct which holds the option information
    public struct Options {
        /// The location which should be displayed or in a route the destination
        public let location: CLLocationCoordinate2D
        public let navigationMode: NavigationMode
        private let _locationName: String?
        public var locationName: String? { _locationName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) }
        
        /// Could be added later if needed
//        public let mapMode
//        public let zoomLevel: Int?
//        public let mapCenter: CLLocationCoordinate2D?
        
        public init(location: CLLocationCoordinate2D, navigationMode: NavigationApp.NavigationMode, locationName: String? = nil) {
            self.location = location
            self.navigationMode = navigationMode
            self._locationName = locationName
        }
    }
}


// MARK: - NavigationApp.NavigationMode

extension NavigationApp {

    /// All the available navigation modes
    public enum NavigationMode {
        /// This will just show the location on the map
        case showOnMap
        /// This will show the route to the location.
        /// Optional a directions mode can be added. Will use the default if not set.
        /// Optional there can also be a start location. Will use the user location if not set.
        case route(directionsMode: DirectionsMode?, startLocation: CLLocationCoordinate2D?)
    }
}


// MARK: - NavigationApp.DirectionsMode

extension NavigationApp {
    
    /// All the available directions modes for `self`
    public var availableDirectionsModes: [DirectionsMode] { DirectionsMode.availableDirectionsModes(for: self) }
    
    /// All the available direction modes.
    /// Depending on the navigation app and region not all of them might be available
    public enum DirectionsMode: CaseIterable {
        /// Driving route
        case driving
        /// Walking route
        case walking
        /// Transit route
        case transit
        /// Bicyle route
        case bicycling
        
        /// A list of all the available `DirectionsMode` cases for the passed in `navigationApp`
        /// - Parameter navigationApp: The navigation app for thich the available direction modes are needed
        /// - Returns: All the available direction modes for the passed in `navigationApp`
        public static func availableDirectionsModes(for navigationApp: NavigationApp) -> [DirectionsMode] {
            DirectionsMode.allCases.filter { $0.directionModeKey(for: navigationApp) != nil }
        }
        
        /// Will provide the direction mode key for the provided `navigationApp` for `self`
        /// - Parameter navigationApp: The navigation app for which the direction mode key is needed
        /// - Returns: The direction mode key if available
        internal func directionModeKey(for navigationApp: NavigationApp) -> String? {
            switch navigationApp {
            case .appleMaps: return appleMapsKey
            case .googleMaps: return googleMapsKey
            case .organicMaps: return organicMapsKey
            case .mapsMe: return mapsMeKey
            case .sygic: return sygicMapsKey
            case .hereWeGo: return hereWeGoKey
            default: return nil
            }
        }
        
        /// The keys of `self` when apple maps is used
        private var appleMapsKey: String? {
            switch self {
            case .driving: return MKLaunchOptionsDirectionsModeDriving
            case .walking: return MKLaunchOptionsDirectionsModeWalking
            case .transit: return MKLaunchOptionsDirectionsModeTransit
            case .bicycling: return nil
            }
        }
        
        /// The keys of `self` when google maps is used
        private var googleMapsKey: String {
            switch self {
            case .driving: return "driving"
            case .walking: return "walking"
            case .transit: return "transit"
            case .bicycling: return "bicycling"
            }
        }
        
        /// The keys of `self` when organic maps is used
        private var organicMapsKey: String {
            switch self {
            case .driving: return "vehicle"
            case .walking: return "pedestrian"
            case .transit: return "transit"
            case .bicycling: return "bicycle"
            }
        }
        
        /// The keys of `self` when maps me is used
        private var mapsMeKey: String? {
            switch self {
            case .driving: return "vehicle"
            case .walking: return "pedestrian"
            case .transit: return nil
            case .bicycling: return "bicycle"
            }
        }
        
        /// The keys of `self` when sygic is used
        private var sygicMapsKey: String? {
            switch self {
            case .driving: return "drive"
            case .walking: return "walk"
            case .transit: return nil
            case .bicycling: return nil
            }
        }
        
        /// The keys of `self` when here we go app is used
        private var hereWeGoKey: String {
            switch self {
            case .driving: return "d"
            case .walking: return "w"
            case .transit: return "a"
            case .bicycling: return "b"
                /// "t" would be "ride share"/"taxi"/"uber"  something like this
            }
        }
    }
}
