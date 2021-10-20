//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData

open class NotificareAbstractDatabase {
    private let name: String
    private let rebuildOnVersionChange: Bool

    private var databaseVersionKey: String {
        "re.notifica.database_version.\(name)"
    }

    public lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.url(forResource: name, withExtension: ".momd"),
              let model = NSManagedObjectModel(contentsOf: path)
        else {
            NotificareLogger.error("Failed to load CoreData's models.")
            fatalError("Failed to load CoreData's models")
        }

        return NSPersistentContainer(name: name, managedObjectModel: model)
    }()

    public var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    public init(name: String, rebuildOnVersionChange: Bool = true) {
        self.name = name
        self.rebuildOnVersionChange = rebuildOnVersionChange
    }

    public func configure() {
        // Force the container to be loaded.
        _ = persistentContainer

        if let currentVersion = UserDefaults.standard.string(forKey: databaseVersionKey), currentVersion != Notificare.SDK_VERSION {
            NotificareLogger.debug("Database version mismatch. Recreating...")
            removeStore()
        }

        NotificareLogger.debug("Loading database: \(name)")
        loadStore()
    }

    public func saveChanges() {
        guard context.hasChanges else {
            return
        }

        do {
            try context.save()
        } catch {
            NotificareLogger.error("Failed to persist changes to CoreData.")
            NotificareLogger.debug("\(error)")
        }
    }

    private func loadStore() {
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                NotificareLogger.error("Failed to load CoreData store '\(self.name)': \(error)")
                fatalError("Failed to load CoreData store.")
            }

            // Update the database version in local storage.
            UserDefaults.standard.set(Notificare.SDK_VERSION, forKey: self.databaseVersionKey)
        }
    }

    private func removeStore() {
        guard
            let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?.appendingPathComponent("\(name).sqlite"),
            FileManager.default.fileExists(atPath: url.path)
        else {
            NotificareLogger.debug("Database file not found.")
            return
        }

        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: "sqlite")
            NotificareLogger.debug("Database removed.")
        } catch {
            NotificareLogger.debug("Failed to remove database.")
        }
    }
}
