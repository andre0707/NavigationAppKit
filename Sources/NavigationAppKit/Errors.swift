//
//  Errors.swift
//  
//
//  Created by Andre Albach on 27.08.23.
//

import Foundation

/// All the errors which can occout when working with this package
public enum Errors: Error {
    /// Thrown when there was an error opening Apple Maps app via MapKit api
    case mapKitAPI
    /// Thrown if the picked navigation app does not support adding a start location, but a start location was added anyway
    case doesNotSupportStartLocation
    /// Thrown if the start location is missing, but is required
    case requiresStartLocation
    /// Thrown if routing is not supported
    case doesNotSupportRouting
    /// Thrown if the selected direction mode is not supported by this app. Try a different one. `.driving` should work
    case unsupportedDirectionsMode
    /// Thrown if there is something wrong with the app url
    case invalidAppUrl
}
