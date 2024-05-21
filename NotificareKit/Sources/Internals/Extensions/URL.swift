//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

extension URL {
    public func appendingQueryComponent(name: String, value: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var queryItems = components.queryItems ?? []

        // Upsert the given query parameter
        if var existing = queryItems.first(where: { $0.name == name }) {
            existing.value = value
        } else {
            queryItems.append(URLQueryItem(name: name, value: value))
        }

        // Update the query items.
        components.queryItems = queryItems

        return components.url!
    }

    public mutating func appendQueryComponent(name: String, value: String) {
        self = appendingQueryComponent(name: name, value: value)
    }
}
