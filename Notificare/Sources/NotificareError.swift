//
// Created by Helder Pinhal on 15/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation

public enum NotificareError: Error {
    case networkFailure(cause: NotificareNetworkError)
    case parsingFailure
}
