//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDeviceModule: AnyObject {
    var currentDevice: NotificareDevice? { get }

    var preferredLanguage: String? { get }

    func register(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>)

    func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<Void>)

    func fetchTags(_ completion: @escaping NotificareCallback<[String]>)

    func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>)

    func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>)

    func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>)

    func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>)

    func clearTags(_ completion: @escaping NotificareCallback<Void>)

    func fetchDoNotDisturb(_ completion: @escaping NotificareCallback<NotificareDoNotDisturb?>)

    func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb, _ completion: @escaping NotificareCallback<Void>)

    func clearDoNotDisturb(_ completion: @escaping NotificareCallback<Void>)

    func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData>)

    func updateUserData(_ userData: NotificareUserData, _ completion: @escaping NotificareCallback<Void>)
}

public protocol NotificareInternalDeviceModule: AnyObject {
    func registerTemporary(_ completion: @escaping NotificareCallback<Void>)

    func registerAPNS(token: String, _ completion: @escaping NotificareCallback<Void>)
}
