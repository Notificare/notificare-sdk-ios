//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData

open class NotificareAbstractDatabase {
    private let name: String
    private let rebuildOnVersionChange: Bool
    private let mergePolicy: NSMergePolicy?

    private var databaseVersionKey: String {
        "re.notifica.database_version.\(name)"
    }

    private var databaseUrl: URL {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("\(name).sqlite")
    }

    public lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.url(forResource: name, withExtension: ".momd"),
              let model = NSManagedObjectModel(contentsOf: path)
        else {
            logger.error("Failed to load CoreData's models.")
            fatalError("Failed to load CoreData's models")
        }

        let container = NSPersistentContainer(name: name, managedObjectModel: model)

        if shouldOverrideDatabaseFileProtection {
            let storeDescription = NSPersistentStoreDescription(url: databaseUrl)
            storeDescription.type = NSSQLiteStoreType
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.setOption(FileProtectionType.none as NSObject, forKey: NSPersistentStoreFileProtectionKey)

            container.persistentStoreDescriptions = [storeDescription]
        }

        return container
    }()

    public lazy var backgroundContext: NSManagedObjectContext = {
        persistentContainer.newBackgroundContext()
    }()

    private var hasLoadedPersistentStores: Bool {
        !persistentContainer.persistentStoreCoordinator.persistentStores.isEmpty
    }

    private var shouldOverrideDatabaseFileProtection: Bool {
        Notificare.shared.options?.overrideDatabaseFileProtection ?? false
    }

    public init(name: String, rebuildOnVersionChange: Bool = true, mergePolicy: NSMergePolicy? = nil) {
        self.name = name
        self.rebuildOnVersionChange = rebuildOnVersionChange
        self.mergePolicy = mergePolicy
    }

    public func configure() {
        // Force the container to be loaded.
        _ = persistentContainer

        if let currentVersion = UserDefaults.standard.string(forKey: databaseVersionKey), currentVersion != Notificare.SDK_VERSION {
            logger.debug("Database version mismatch. Recreating...")
            removeStore()
        }

        logger.debug("Loading database: \(name)")
        loadStore()

        if let mergePolicy {
            backgroundContext.mergePolicy = mergePolicy
        }
    }

    public func ensureLoadedStores() {
        guard !hasLoadedPersistentStores else {
            return
        }

        logger.debug("Trying to load database: \(name)")
        loadStore()
    }

    public func saveChanges() async {
        await backgroundContext.performCompat {
            guard self.backgroundContext.hasChanges else {
                return
            }

            guard self.hasLoadedPersistentStores else {
                logger.warning("Cannot save the database changes before the persistent stores are loaded.")
                return
            }

            do {
                try self.backgroundContext.save()
            } catch {
                logger.error("Failed to persist changes to CoreData.", error: error)
            }
        }
    }

    private func loadStore() {
        let stores = persistentContainer.persistentStoreCoordinator.persistentStores

        if !stores.isEmpty {
            logger.debug("Reloading CoreData stores for '\(self.name)'.")

            for store in stores {
                do {
                    try persistentContainer.persistentStoreCoordinator.remove(store)
                } catch {
                    logger.error("Failed to reload store.", error: error)
                    return
                }
            }
        }

        persistentContainer.loadPersistentStores { _, error in
            if let error {
                logger.error("Failed to load CoreData store '\(self.name)'.", error: error)
                return
            }

            // Update the database version in local storage.
            UserDefaults.standard.set(Notificare.SDK_VERSION, forKey: self.databaseVersionKey)
        }
    }

    private func removeStore() {
        guard FileManager.default.fileExists(atPath: databaseUrl.path) else {
            logger.debug("Database file not found.")
            return
        }

        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: databaseUrl, ofType: "sqlite")
            logger.debug("Database removed.")
        } catch {
            logger.debug("Failed to remove database.")
        }
    }
}
