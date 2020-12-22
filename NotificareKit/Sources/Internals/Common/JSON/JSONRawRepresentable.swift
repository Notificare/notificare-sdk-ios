//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

extension JSON: RawRepresentable {
    public init?(rawValue: Data) {
        do {
            let decoder = JSONDecoder()
            self = try decoder.decode(JSON.self, from: rawValue)
        } catch {
            print(error)
            return nil
        }
    }

    public var rawValue: Data {
        do {
            let encoder = JSONEncoder()
            return try encoder.encode(self)
        } catch {
            fatalError("\(error)")
        }
    }
}

extension JSON: CustomStringConvertible {
    public var description: String {
        var ret: String?
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            ret = String(data: data, encoding: .utf8)
        }
        return ret ?? "<<error>>"
    }
}
