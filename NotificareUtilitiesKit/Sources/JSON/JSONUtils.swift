//
// Copyright (c) 2024 Notificare. All rights reserved.
//

public enum JSONUtils {
    public static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(NotificareIsoDateUtils.parser)

        return decoder
    }()

    public static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(NotificareIsoDateUtils.formatter)

        return encoder
    }()

}
