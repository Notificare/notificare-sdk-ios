//
// Created by Helder Pinhal on 24/07/2020.
// Copyright (c) 2020 Notificare. All rights reserved.
//

import Foundation
import UIKit

private typealias ApplicationDidBecomeActive = @convention(c) (Any, Selector, UIApplication) -> Void
private typealias ApplicationWillResignActive = @convention(c) (Any, Selector, UIApplication) -> Void

private struct AssociatedObjectKeys {
    static var originalClass = "Notificare_OriginalClass"
    static var originalImplementations = "Notificare_OriginalImplementations"
}

private var gOriginalAppDelegate: UIApplicationDelegate?
private var gAppDelegateSubClass: AnyClass?

public class NotificareSwizzler: NSProxy {

    public static func setup(withRemoteNotifications: Bool = false) {
        // Let the property be initialized and run its block.
        _ = runOnce

        if withRemoteNotifications {
            _ = runOnceRemoteNotifications
        }
    }

    /// Using Swift's lazy evaluation of a static property we get the same
    /// thread-safety and called-once guarantees as dispatch_once provided.
    private static let runOnce: () = {
        weak var appDelegate = UIApplication.shared.delegate
        proxyAppDelegate(appDelegate)
    }()

    private static let runOnceRemoteNotifications: () = {
        // TODO implement APNS methods
    }()

    private static func proxyAppDelegate(_ appDelegate: UIApplicationDelegate?) {
        guard let appDelegate = appDelegate else {
            Notificare.shared.logger.warning("Could not create the App Delegate Proxy. The original App Delegate instance is nil.")
            return
        }

        gAppDelegateSubClass = createSubClass(from: appDelegate)
        self.reassignAppDelegate()
    }

    private static func reassignAppDelegate() {
        weak var delegate = UIApplication.shared.delegate
        UIApplication.shared.delegate = nil
        UIApplication.shared.delegate = delegate
        gOriginalAppDelegate = delegate
        // TODO observe UIApplication
    }

    /// Creates a new subclass of the class of the given object and sets the isa value of the given object to the new subclass.
    /// Additionally this copies methods to that new subclass that allow us to intercept UIApplicationDelegate methods.
    /// This is better known as isa swizzling.
    ///
    /// - Parameter originalDelegate: The object to which you want to isa swizzle.
    /// - Returns: The new subclass.
    private static func createSubClass(from originalDelegate: UIApplicationDelegate) -> AnyClass? {
        let originalClass = type(of: originalDelegate)
        let newClassName = "\(originalClass)_\(UUID().uuidString)"

        guard NSClassFromString(newClassName) == nil else {
            Notificare.shared.logger.warning("Could not create the App Delegate Proxy. The subclass already exists.")
            return nil
        }

        // Register the new class as subclass of the real one. Do not allocate more than the real class size.
        guard let subClass = objc_allocateClassPair(originalClass, newClassName, 0) else {
            Notificare.shared.logger.warning("Could not create the App Delegate Proxy. The subclass already exists.")
            return nil
        }

        // Add NotificareSwizzler's UIApplicationDelegate methods to the subclass and store the real implementations
        // so the invocations can be forwarded to the real ones.
        self.createMethodImplementations(in: subClass, withOriginalDelegate: originalDelegate)

        // Override the description too so the custom class name will not show up.
        self.overrideDescription(in: subClass)

        // Store the original class in a fake property of the original delegate.
        objc_setAssociatedObject(originalDelegate, &AssociatedObjectKeys.originalClass, originalClass, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // The subclass size has to be exactly the same size with the original class size. The subclass
        // cannot have more ivars/properties than its superclass since it will cause an offset in memory
        // that can lead to overwriting the isa of an object in the next frame.
        guard class_getInstanceSize(originalClass) == class_getInstanceSize(subClass) else {
            Notificare.shared.logger.warning("Could not create the App Delegate Proxy. The original class' and subclass' sizes do not match.")
            return nil
        }

        // Make the newly created class to be the subclass of the real App Delegate class.
        objc_registerClassPair(subClass)
        if object_setClass(originalDelegate, subClass) != nil {
            Notificare.shared.logger.info("Successfully created the App Delegate Proxy. To disable automatic proxy, set the flag 'swizzlingEnabled' to NO on the Notificare.plist.")
        }

        return subClass
    }

    private static func createMethodImplementations(
            in subClass: AnyClass,
            withOriginalDelegate originalDelegate: UIApplicationDelegate
    ) {
        let originalClass = type(of: originalDelegate)
        var originalImplementationsStore: [String: NSValue] = [:]

        // For applicationDidBecomeActive:
        self.proxyInstanceMethod(
                toClass: subClass,
                withSelector: #selector(applicationDidBecomeActive(_:)),
                fromClass: NotificareSwizzler.self,
                fromSelector: #selector(applicationDidBecomeActive(_:)),
                withOriginalClass: originalClass,
                storeOriginalImplementationInto: &originalImplementationsStore)

        // For applicationWillResignActive:
        self.proxyInstanceMethod(
                toClass: subClass,
                withSelector: #selector(applicationWillResignActive(_:)),
                fromClass: NotificareSwizzler.self,
                fromSelector: #selector(applicationWillResignActive(_:)),
                withOriginalClass: originalClass,
                storeOriginalImplementationInto: &originalImplementationsStore)

        // Store original implementations
        objc_setAssociatedObject(originalDelegate, &AssociatedObjectKeys.originalImplementations, originalImplementationsStore, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private static func overrideDescription(in subClass: AnyClass) {
        // Override the description so the custom class name will not show up.
        self.addInstanceMethod(
                toClass: subClass,
                toSelector: #selector(description),
                fromClass: NotificareSwizzler.self,
                fromSelector: #selector(originalDescription))
    }

    private static func proxyInstanceMethod(
            toClass destinationClass: AnyClass,
            withSelector destinationSelector: Selector,
            fromClass sourceClass: AnyClass,
            fromSelector sourceSelector: Selector,
            withOriginalClass originalClass: AnyClass,
            storeOriginalImplementationInto originalImplementationsStore: inout [String: NSValue]
    ) {
        self.addInstanceMethod(
                toClass: destinationClass,
                toSelector: destinationSelector,
                fromClass: sourceClass,
                fromSelector: sourceSelector)

        let sourceImplementation = methodImplementation(for: destinationSelector, from: originalClass)
        let sourceImplementationPointer = NSValue(pointer: UnsafePointer(sourceImplementation))

        let destinationSelectorStr = NSStringFromSelector(destinationSelector)
        originalImplementationsStore[destinationSelectorStr] = sourceImplementationPointer
    }

    private static func addInstanceMethod(
            toClass destinationClass: AnyClass,
            toSelector destinationSelector: Selector,
            fromClass sourceClass: AnyClass,
            fromSelector sourceSelector: Selector
    ) {
        let method = class_getInstanceMethod(sourceClass, sourceSelector)!
        let methodImplementation = method_getImplementation(method)
        let methodTypeEncoding = method_getTypeEncoding(method)

        if !class_addMethod(destinationClass, destinationSelector, methodImplementation, methodTypeEncoding) {
            Notificare.shared.logger.warning("Could not add instance method with selector '\(destinationSelector)' as it already exists in the destination class.")
        }
    }

    private static func methodImplementation(for selector: Selector, from fromClass: AnyClass) -> IMP? {
        guard let method = class_getInstanceMethod(fromClass, selector) else {
            return nil
        }

        return method_getImplementation(method)
    }

    private static func originalMethodImplementation(for selector: Selector, object: Any) -> NSValue? {
        let originalImplementationsStore = objc_getAssociatedObject(object, &AssociatedObjectKeys.originalImplementations) as? [String: NSValue]
        return originalImplementationsStore?[NSStringFromSelector(selector)]
    }

    @objc
    private func originalDescription() -> String {
        let originalClass: AnyClass = objc_getAssociatedObject(self, &AssociatedObjectKeys.originalClass) as! AnyClass

        let originalClassName = NSStringFromClass(originalClass)
        let pointerHex = String(format: "%p", unsafeBitCast(self, to: Int.self))

        return "<\(originalClassName): \(pointerHex)>"
    }

    @objc
    private func applicationDidBecomeActive(_ application: UIApplication) {
        Notificare.shared.logger.verbose("Notificare: application did become active")

        let selector = #selector(applicationDidBecomeActive)
        guard let pointer = NotificareSwizzler.originalMethodImplementation(for: selector, object: self),
              let pointerValue = pointer.pointerValue else {

            Notificare.shared.logger.verbose("Could not find an original implementation for selector '\(selector)'.")
            return
        }

        let originalImplementation = unsafeBitCast(pointerValue, to: ApplicationDidBecomeActive.self)
        originalImplementation(self, selector, application)
    }

    @objc
    private func applicationWillResignActive(_ application: UIApplication) {
        Notificare.shared.logger.verbose("Notificare: application will resign active")

        let selector = #selector(applicationWillResignActive)
        guard let pointer = NotificareSwizzler.originalMethodImplementation(for: selector, object: self),
              let pointerValue = pointer.pointerValue else {

            Notificare.shared.logger.verbose("Could not find an original implementation for selector '\(selector)'.")
            return
        }

        let originalImplementation = unsafeBitCast(pointerValue, to: ApplicationWillResignActive.self)
        originalImplementation(self, selector, application)
    }
}
