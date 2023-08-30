//
//  Parameter.swift
//  
//
//  Created by Andre Albach on 27.08.23.
//

import Foundation

/// A struct which represents a url parameter
internal struct Parameter: Equatable {
    /// The key
    let key: String
    /// The value
    let value: String
    
    static func == (lhs: Parameter, rhs: Parameter) -> Bool { lhs.key == rhs.key }
}


extension Array where Element == Parameter {
    /// This will create a parameter string of `self`.
    /// It will be used for urls, so the values will be percent encoded.
    /// The parameters will be joined by & as it is the default in url parameters. You can override the separator though
    func createParameterString(using separator: String = "&") -> String {
        self
            //.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: separator)
    }
}
