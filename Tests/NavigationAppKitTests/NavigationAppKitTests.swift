import XCTest
import CoreLocation
@testable import NavigationAppKit

final class NavigationAppKitTests: XCTestCase {
    
    /// Testing the result of the basic url scheme when providing a destination location
    func test_basicSchemes() throws {
        let location = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
        let options = NavigationApp.Options(location: location,
                                            navigationMode: .showOnMap)
        
        XCTAssertEqual(try NavigationApp.appleMaps.buildFullUrl(with: options), nil)
        XCTAssertEqual(try NavigationApp.googleMaps.buildFullUrl(with: options), URL(string: "comgooglemaps://?q=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.organicMaps.buildFullUrl(with: options), URL(string: "om://map?v=1&ll=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.mapsMe.buildFullUrl(with: options), URL(string: "mapswithme://map?v=1&ll=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.waze.buildFullUrl(with: options), URL(string: "waze://?ll=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.sygic.buildFullUrl(with: options), URL(string: "com.sygic.aura://coordinate%7C8.674230%7C50.586206%7Cshow"))
        XCTAssertEqual(try NavigationApp.hereWeGo.buildFullUrl(with: options), URL(string: "here-location://50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.navigon.buildFullUrl(with: options), URL(string: "navigon://%7C%7C%7C%7C%7C%7C50.586206%7C8.674230"))
    }
    
    /// Testing the result of the basic url scheme when providing a destination location and a name for the location
    func test_schemesWithName() throws {
        let location = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
        let options = NavigationApp.Options(location: location,
                                            navigationMode: .showOnMap,
                                            locationName: "My test location")
        
        XCTAssertEqual(try NavigationApp.appleMaps.buildFullUrl(with: options), nil)
        XCTAssertEqual(try NavigationApp.googleMaps.buildFullUrl(with: options), URL(string: "comgooglemaps://?q=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.organicMaps.buildFullUrl(with: options), URL(string: "om://map?v=1&ll=50.586206,8.674230&n=My%20test%20location"))
        XCTAssertEqual(try NavigationApp.mapsMe.buildFullUrl(with: options), URL(string: "mapswithme://map?v=1&ll=50.586206,8.674230&n=My%20test%20location"))
        XCTAssertEqual(try NavigationApp.waze.buildFullUrl(with: options), URL(string: "waze://?ll=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.sygic.buildFullUrl(with: options), URL(string: "com.sygic.aura://coordinate%7C8.674230%7C50.586206%7CMy%20test%20location%7Cshow"))
        XCTAssertEqual(try NavigationApp.hereWeGo.buildFullUrl(with: options), URL(string: "here-location://50.586206,8.674230,My%20test%20location"))
        XCTAssertEqual(try NavigationApp.navigon.buildFullUrl(with: options), URL(string: "navigon://%7C%7C%7C%7C%7C%7C50.586206%7C8.674230"))
    }
    
    /// Testing the result of the route url when provididing a destination and start location, but no name for the destination
    func test_routesWithStart() throws {
        let destination = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
        let start = CLLocationCoordinate2D(latitude: 50.579869, longitude: 8.662212)
        let options = NavigationApp.Options(location: destination,
                                            navigationMode: .route(directionsMode: nil, startLocation: start))
        
        XCTAssertEqual(try NavigationApp.appleMaps.buildFullUrl(with: options), nil)
        XCTAssertEqual(try NavigationApp.googleMaps.buildFullUrl(with: options), URL(string: "comgooglemaps://?saddr=50.579869,8.662212&daddr=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.organicMaps.buildFullUrl(with: options), URL(string: "om://route?sll=50.579869,8.662212&saddr=Start&dll=50.586206,8.674230&daddr=End&type=vehicle"))
        //XCTAssertEqual(try NavigationApp.mapsMe.buildFullUrl(with: options), URL(string: "mapswithme://route?sll=50.579869,8.662212&saddr=Start&dll=50.586206,8.674230&daddr=End&type=vehicle"))
        XCTAssertThrowsError(try NavigationApp.mapsMe.buildFullUrl(with: options))
        XCTAssertThrowsError(try NavigationApp.waze.buildFullUrl(with: options))
        XCTAssertThrowsError(try NavigationApp.sygic.buildFullUrl(with: options))
        XCTAssertEqual(try NavigationApp.hereWeGo.buildFullUrl(with: options), URL(string: "here-route://50.579869,8.662212/50.586206,8.674230?m=d"))
        XCTAssertEqual(try NavigationApp.navigon.buildFullUrl(with: options), URL(string: "navigon://%7C%7C%7C%7C%7C%7C50.586206%7C8.674230"))
    }
    
    /// Testing the result of the route url when provididing only a destination location
    func test_routesWithoutStart() throws {
        let destination = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
        let options = NavigationApp.Options(location: destination,
                                            navigationMode: .route(directionsMode: nil, startLocation: nil))
        
        XCTAssertEqual(try NavigationApp.appleMaps.buildFullUrl(with: options), nil)
        XCTAssertEqual(try NavigationApp.googleMaps.buildFullUrl(with: options), URL(string: "comgooglemaps://?daddr=50.586206,8.674230"))
        XCTAssertThrowsError(try NavigationApp.organicMaps.buildFullUrl(with: options))
        XCTAssertThrowsError(try NavigationApp.mapsMe.buildFullUrl(with: options))
        XCTAssertEqual(try NavigationApp.waze.buildFullUrl(with: options), URL(string: "waze://?ll=50.586206,8.674230&navigate=yes"))
        XCTAssertEqual(try NavigationApp.sygic.buildFullUrl(with: options), URL(string: "com.sygic.aura://coordinate%7C8.674230%7C50.586206%7Cdrive"))
        XCTAssertEqual(try NavigationApp.hereWeGo.buildFullUrl(with: options), URL(string: "here-route://mylocation/50.586206,8.674230?m=d"))
        XCTAssertEqual(try NavigationApp.navigon.buildFullUrl(with: options), URL(string: "navigon://%7C%7C%7C%7C%7C%7C50.586206%7C8.674230"))
    }
    
    /// Testing the result of the route url when provididing a destination and start location for walking mode
    func test_routesWalkingWithStart() throws {
        let destination = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
        let start = CLLocationCoordinate2D(latitude: 50.579869, longitude: 8.662212)
        let options = NavigationApp.Options(location: destination,
                                            navigationMode: .route(directionsMode: .walking, startLocation: start))
        
        XCTAssertEqual(try NavigationApp.appleMaps.buildFullUrl(with: options), nil)
        XCTAssertEqual(try NavigationApp.googleMaps.buildFullUrl(with: options), URL(string: "comgooglemaps://?directionsmode=walking&saddr=50.579869,8.662212&daddr=50.586206,8.674230"))
        XCTAssertEqual(try NavigationApp.organicMaps.buildFullUrl(with: options), URL(string: "om://route?sll=50.579869,8.662212&saddr=Start&dll=50.586206,8.674230&daddr=End&type=pedestrian"))
//        XCTAssertEqual(try NavigationApp.mapsMe.buildFullUrl(with: options), URL(string: "mapswithme://route?sll=50.579869,8.662212&saddr=Start&dll=50.586206,8.674230&daddr=End&type=pedestrian"))
        XCTAssertThrowsError(try NavigationApp.mapsMe.buildFullUrl(with: options))
        XCTAssertThrowsError(try NavigationApp.waze.buildFullUrl(with: options))
        XCTAssertThrowsError(try NavigationApp.sygic.buildFullUrl(with: options))
        XCTAssertEqual(try NavigationApp.hereWeGo.buildFullUrl(with: options), URL(string: "here-route://50.579869,8.662212/50.586206,8.674230?m=w"))
        XCTAssertEqual(try NavigationApp.navigon.buildFullUrl(with: options), URL(string: "navigon://%7C%7C%7C%7C%7C%7C50.586206%7C8.674230"))
    }
    
    /// Testing the result of the route url when provididing a destination location for walking mode
    func test_routesWalkingWithoutStart() throws {
        let destination = CLLocationCoordinate2D(latitude: 50.586206, longitude: 8.674230)
        let options = NavigationApp.Options(location: destination,
                                            navigationMode: .route(directionsMode: .walking, startLocation: nil))
        
        XCTAssertEqual(try NavigationApp.appleMaps.buildFullUrl(with: options), nil)
        XCTAssertEqual(try NavigationApp.googleMaps.buildFullUrl(with: options), URL(string: "comgooglemaps://?directionsmode=walking&daddr=50.586206,8.674230"))
        XCTAssertThrowsError(try NavigationApp.organicMaps.buildFullUrl(with: options))
//        XCTAssertEqual(try NavigationApp.mapsMe.buildFullUrl(with: options), URL(string: "mapswithme://route?sll=50.579869,8.662212&saddr=Start&dll=50.586206,8.674230&daddr=End&type=pedestrian"))
        XCTAssertThrowsError(try NavigationApp.mapsMe.buildFullUrl(with: options))
        XCTAssertThrowsError(try NavigationApp.waze.buildFullUrl(with: options))
        XCTAssertEqual(try NavigationApp.sygic.buildFullUrl(with: options), URL(string: "com.sygic.aura://coordinate%7C8.674230%7C50.586206%7Cwalk"))
        XCTAssertEqual(try NavigationApp.hereWeGo.buildFullUrl(with: options), URL(string: "here-route://mylocation/50.586206,8.674230?m=w"))
        XCTAssertEqual(try NavigationApp.navigon.buildFullUrl(with: options), URL(string: "navigon://%7C%7C%7C%7C%7C%7C50.586206%7C8.674230"))
    }
}
