//
// Copyright (c) 2020 Notificare. All rights reserved.
//

import CoreData
import Foundation

class NotificareCoreDataManager {
    private lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.url(forResource: "NotificareCoreData", withExtension: ".momd"),
            let model = NSManagedObjectModel(contentsOf: path)
        else {
            Notificare.shared.logger.error("Failed to load CoreData's models.")
            fatalError("Failed to load CoreData's models")
        }

        let container = NSPersistentContainer(name: "NotificareCoreData", managedObjectModel: model)

        container.loadPersistentStores { _, error in
            if let error = error {
                Notificare.shared.logger.error("Failed to load CoreData's stores.")
                Notificare.shared.logger.debug("\(error)")

                fatalError("Failed to load CoreData's stores: \(error)")
            }

            Notificare.shared.logger.info("CoreData store finished loading")
        }

        return container
    }()

    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func configure() {
        // Force the container to be loaded.
        _ = persistentContainer
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
}
