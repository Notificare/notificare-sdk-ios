//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

class NotificareCoreDataManager {
    private static let databaseName = "NotificareCoreData"
    private static let databaseType = "sqlite"

    private lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.url(forResource: NotificareCoreDataManager.databaseName, withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: path)
        else {
            Notificare.shared.logger.error("Failed to load CoreData's models.")
            fatalError("Failed to load CoreData's models")
        }

        return NSPersistentContainer(name: NotificareCoreDataManager.databaseName, managedObjectModel: model)
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func configure() {
        // Force the container to be loaded.
        _ = persistentContainer
    }

    func launch(_ completion: @escaping (Result<Void, Error>) -> Void) {
        if let currentVersion = NotificareLocalStorage.currentDatabaseVersion,
            currentVersion != NotificareConstants.databaseVersion
        {
            Notificare.shared.logger.debug("Local database version mismatch. Migration required.")
            rebuildStore(completion)
        } else {
            Notificare.shared.logger.debug("Loading local database.")
            loadStore(completion)
        }
    }

    func add(_ event: NotificareEvent) {
        _ = event.toManaged(context: context)
        save()
    }

    func remove(_ event: NotificareCoreDataEvent) {
        context.delete(event)
        save()
    }

    func fetchEvents() throws -> [NotificareCoreDataEvent] {
        let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
        let result = try context.fetch(request)

        return result
    }

    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Notificare.shared.logger.error("Failed to save CoreData changes.")
                Notificare.shared.logger.debug("\(error)")
            }
        } else {
            Notificare.shared.logger.verbose("Nothing to save.")
        }
    }

    private func loadStore(_ completion: @escaping (Result<Void, Error>) -> Void) {
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            NotificareLocalStorage.currentDatabaseVersion = NotificareConstants.databaseVersion
            completion(.success(()))
        }
    }

    private func rebuildStore(_ completion: @escaping (Result<Void, Error>) -> Void) {
        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?.appendingPathComponent("\(NotificareCoreDataManager.databaseName).\(NotificareCoreDataManager.databaseType)"),
            FileManager.default.fileExists(atPath: url.path)
        {
            Notificare.shared.logger.debug("Removing local database.")
            if let _ = try? persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: "sqlite") {
                Notificare.shared.logger.debug("Local database removed.")
            } else {
                Notificare.shared.logger.debug("Failed to remove local database.")
            }
        } else {
            Notificare.shared.logger.debug("Local database file not found.")
        }

        loadStore(completion)
    }
}
