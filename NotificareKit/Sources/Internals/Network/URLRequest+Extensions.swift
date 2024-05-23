//
// Copyright (c) 2020 Notificare. All rights reserved.
//

extension URLRequest {
//    mutating func setBasicAuthentication(username: String, password: String) {
//        let base64encoded = "\(username):\(password)"
//            .data(using: .utf8)!
//            .base64EncodedString()
//
//        addValue("Basic \(base64encoded)", forHTTPHeaderField: "Authorization")
//    }

//    mutating func setBearerAuthentication(token: String) {
//        addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//    }

    public mutating func setNotificareHeaders() {
        setValue(Notificare.SDK_VERSION, forHTTPHeaderField: "X-Notificare-SDK-Version")
        setValue(NotificareUtils.applicationVersion, forHTTPHeaderField: "X-Notificare-App-Version")
    }

    public mutating func setMethod(_ method: String, payload: Data? = nil) {
        httpMethod = method
        httpBody = payload

        if payload != nil {
            setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}
