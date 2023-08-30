//
//  CLLocationDegrees.swift
//  
//
//  Created by Andre Albach on 27.08.23.
//

import CoreLocation

extension CLLocationDegrees {
    
    /// `self` formatted as a string. This will include 6 figures after decimal
    var stringFormatted: String { String(format: "%.6f", self) }
}
