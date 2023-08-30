//
//  CLLocationCoordinate2D.swift
//  
//
//  Created by Andre Albach on 27.08.23.
//

import CoreLocation

extension CLLocationCoordinate2D {
    
    /// The default parameter format for `self`.
    /// Will look like this: 50.123456,8.345600
    var defaultParameterFormatted: String { String(format: "%.6f,%.6f", latitude, longitude) }
}
