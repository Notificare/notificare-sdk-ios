//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import Foundation

public protocol NotificareDeviceModule: AnyObject {
    /// Provides the current registered device information.
    var currentDevice: NotificareDevice? { get }

    /// Provides the preferred language of the current device for notifications and messages.
    var preferredLanguage: String? { get }

    /// Registers a user for the device, with a callback.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `null`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    ///   - completion: A callback that will be invoked with the result of the register operation.
    @available(*, deprecated, renamed: "updateUser")
    func register(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>)

    /// Registers a user for the device.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `null`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    @available(*, deprecated, renamed: "updateUser")
    func register(userId: String?, userName: String?) async throws

    /// Updates the user information for the device, with a callback.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `null`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    ///   - completion: A callback that will be invoked with the result of the update user operation.
    func updateUser(userId: String?, userName: String?, _ completion: @escaping NotificareCallback<Void>)

    /// Updates the user information for the device.
    ///
    /// To register the device anonymously, set both `userId` and `userName` to `null`.
    ///
    /// - Parameters:
    ///   - userId: Optional user identifier.
    ///   - userName: Optional user name.
    func updateUser(userId: String?, userName: String?) async throws

    /// Updates the preferred language setting for the device, with a callback.
    /// - Parameters:
    ///   - preferredLanguage: The preferred language code.
    ///   - completion: A callback that will be invoked with the result of the update preferred language operation.
    func updatePreferredLanguage(_ preferredLanguage: String?, _ completion: @escaping NotificareCallback<Void>)

    /// Updates the preferred language setting for the device.
    /// - Parameter preferredLanguage: The preferred language code.
    func updatePreferredLanguage(_ preferredLanguage: String?) async throws

    /// Fetches the tags associated with the device, with a callback.
    /// - Parameters:
    ///   - completion: A callback that will be invoked with the result of the fetch tags operation.
    func fetchTags(_ completion: @escaping NotificareCallback<[String]>)

    /// Fetches the tags associated with the device.
    /// - Returns: A list of tags currently associated with the device.
    func fetchTags() async throws -> [String]

    /// Adds a single tag to the device, with a callback.
    /// - Parameters:
    ///   - tag: The tag to add.
    ///   - completion: A callback that will be invoked with the result of the add tag operation.
    func addTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>)

    /// Adds a single tag to the device.
    /// - Parameter tag: The tag to add.
    func addTag(_ tag: String) async throws

    /// Adds multiple tags to the device, with a callback.
    /// - Parameters:
    ///   - tags: A list of tags to add.
    ///   - completion: A callback that will be invoked with the result of the add tags operation.
    func addTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>)

    /// Adds multiple tags to the device.
    /// - Parameter tags: A list of tags to add.
    func addTags(_ tags: [String]) async throws

    /// Removes a specific tag from the device., wit a callback
    /// - Parameters:
    ///   - tag: The tag to remove.
    ///   - completion: A callback that will be invoked with the result of the remove tag operation.
    func removeTag(_ tag: String, _ completion: @escaping NotificareCallback<Void>)

    /// Removes a specific tag from the device.
    /// - Parameter tag: The tag to remove.
    func removeTag(_ tag: String) async throws

    /// Removes multiple tags from the device, with a callback.
    /// - Parameters:
    ///   - tags: A list of tags to remove.
    ///   - completion: A callback that will be invoked with the result of the remove tags operation.
    func removeTags(_ tags: [String], _ completion: @escaping NotificareCallback<Void>)

    /// Removes multiple tags from the device.
    /// - Parameter tags: A list of tags to remove.
    func removeTags(_ tags: [String]) async throws

    /// Clears all tags from the device, with a callback.
    /// - Parameter completion: A callback that will be invoked with the result of the clear tags operation.
    func clearTags(_ completion: @escaping NotificareCallback<Void>)

    /// Clears all tags from the device.
    func clearTags() async throws

    /// Fetches the "Do Not Disturb" (DND) settings for the device, with a callback.
    /// - Parameter completion: A callback that will be invoked with the result of the fetch dnd operation.
    func fetchDoNotDisturb(_ completion: @escaping NotificareCallback<NotificareDoNotDisturb?>)

    /// Fetches the "Do Not Disturb" (DND) settings for the device.
    /// - Returns: The current DND settings, or `null` if none are set.
    func fetchDoNotDisturb() async throws -> NotificareDoNotDisturb?

    /// Updates the "Do Not Disturb" (DND) settings for the device, with a callback.
    /// - Parameters:
    ///   - dnd: The new DND settings to apply.
    ///   - completion: A callback that will be invoked with the result of the update dnd operation.
    func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb, _ completion: @escaping NotificareCallback<Void>)

    /// Updates the "Do Not Disturb" (DND) settings for the device.
    /// - Parameter dnd: The new DND settings to apply.
    func updateDoNotDisturb(_ dnd: NotificareDoNotDisturb) async throws

    /// Clears the "Do Not Disturb" (DND) settings for the device, with a callback.
    /// - Parameter completion: A callback that will be invoked with the result of the clear dnd operation.
    func clearDoNotDisturb(_ completion: @escaping NotificareCallback<Void>)

    /// Clears the "Do Not Disturb" (DND) settings for the device.
    func clearDoNotDisturb() async throws

    /// Fetches the user data associated with the device, with a callback.
    /// - Parameter completion: A callback that will be invoked with the result of the fetch user data operation.
    func fetchUserData(_ completion: @escaping NotificareCallback<NotificareUserData>)

    /// Fetches the user data associated with the device.
    /// - Returns: The current user data.
    func fetchUserData() async throws -> NotificareUserData

    /// Updates the custom user data associated with the device.
    /// - Parameters:
    ///   - userData: The updated user data to associate with the device.
    ///   - completion: A callback that will be invoked with the result of the update user data operation.
    func updateUserData(_ userData: NotificareUserData, _ completion: @escaping NotificareCallback<Void>)

    /// Updates the custom user data associated with the device.
    /// - Parameter userData: The updated user data to associate with the device.
    func updateUserData(_ userData: NotificareUserData) async throws
}
