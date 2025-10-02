//
//  URLExtensions.swift
//  Boxfort Plus
//
//  Created by Matthew Ryan on 2/29/24.
//

import Foundation

extension URL {
    var queryParameters: [String: String]? {
        URLComponents(string: self.absoluteString)?.queryItems?.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
