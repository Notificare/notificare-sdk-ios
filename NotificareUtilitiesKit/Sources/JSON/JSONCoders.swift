//
// Copyright (c) 2024 Notificare. All rights reserved.
//

extension JSONDecoder {
    public static var notificare: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Date.isoDateParser)

        return decoder
    }
}

extension JSONEncoder {
    public static var notificare: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(Date.isoDateFormatter)

        return encoder
    }
}
