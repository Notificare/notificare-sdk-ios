//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDeviceModule: AnyObject {
    var currentDevice: NotificareDevice? { get }

    var preferredLanguage: String? { get }

    func register(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func register(userId: String?, userName: String?) async throws

    func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func updatePreferredLanguage(_ preferredLanguage: String?) async throws

    func fetchTags(_ completion: @escaping NotificareCallback<[String]>)

    @available(iOS 13.0, *)
    func fetchTags() async throws -> [String]

    func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func addTag(_ tag: String) async throws

    func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func addTags(_ tags: [String]) async throws

    func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func removeTag(_ tag: String) async throws

    func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func removeTags(_ tags: [String]) async throws

    func clearTags(_ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func clearTags() async throws

    func fetchDoNotDisturb(_ completion: @escaping NotificareCallback<NotificareDoNotDisturb?>)

    @available(iOS 13.0, *)
    func fetchDoNotDisturb() async throws -> NotificareDoNotDisturb?

    func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb) async throws

    func clearDoNotDisturb(_ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func clearDoNotDisturb() async throws

    func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData>)

    @available(iOS 13.0, *)
    func fetchUserData() async throws -> NotificareUserData

    func updateUserData(_ userData: NotificareUserData, _ completion: @escaping NotificareCallback<Void>)

    @available(iOS 13.0, *)
    func updateUserData(_ userData: NotificareUserData) async throws
}

public protocol NotificareInternalDeviceModule: AnyObject {
    func registerTemporary(_ completion: @escaping NotificareCallback<Void>)

    func registerAPNS(token: String, _ completion: @escaping NotificareCallback<Void>)
}
