//
// Copyright (c) 2021 Notificare. All rights reserved.
//

import CoreData

open class NotificareDatabase {
    private let name: String
    private let rebuildOnVersionChange: Bool

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

//        if let currentVersion = NotificareUserDefaults.currentDatabaseVersion,
//           currentVersion != NotificareDefinitions.databaseVersion
//        {
//            NotificareLogger.debug("Local database version mismatch. Migration required.")
//            rebuildStore(completion)
//        } else {
        NotificareLogger.debug("Loading local database.")
        loadStore { result in
            switch result {
            case .success:
                break

            case let .failure(error):
                NotificareLogger.error("Failed to load CoreData store '\(self.name)': \(error)")
                fatalError("Failed to load CoreData store.")
            }
        }
//        }
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

    private func loadStore(_ completion: @escaping (Result<Void, Error>) -> Void) {
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

//            NotificareUserDefaults.currentDatabaseVersion = NotificareDefinitions.databaseVersion
            completion(.success(()))
        }
    }

    private func rebuildStore(_ completion: @escaping (Result<Void, Error>) -> Void) {
        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("\(name).sqlite"),
            FileManager.default.fileExists(atPath: url.path)
        {
            NotificareLogger.debug("Removing local database.")
            do {
                try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: "sqlite")
                NotificareLogger.debug("Local database removed.")
            } catch {
                NotificareLogger.debug("Failed to remove local database.")
            }
        } else {
            NotificareLogger.debug("Local database file not found.")
        }

        loadStore(completion)
    }
}
