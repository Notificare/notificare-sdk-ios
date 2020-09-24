//
//  NotificareCoreDataManager.swift
//  Notificare
//
//  Created by Helder Pinhal on 04/09/2020.
//  Copyright © 2020 Notificare. All rights reserved.
//

import Foundation
import CoreData

class NotificareCoreDataManager {

    private lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle(for: type(of: self))

        guard let path = bundle.url(forResource: "NotificareCoreData", withExtension: ".momd"),
              let model = NSManagedObjectModel(contentsOf: path) else {

            Notificare.shared.logger.error("Failed to load CoreData's models.")
            fatalError("Failed to load CoreData's models")
        }

        let container = NSPersistentContainer(name: "NotificareCoreData", managedObjectModel: model)

        container.loadPersistentStores { (_, error) in
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
        self.persistentContainer.viewContext
    }


    func configure() {
        // Force the container to be loaded.
        _ = persistentContainer
    }

    func add(_ event: NotificareEvent) {
        _ = event.toManaged(context: self.context)
        self.save()
    }
    
    func remove(_ event: NotificareCoreDataEvent) {
        self.context.delete(event)
        self.save()
    }

    func fetchEvents() throws -> [NotificareCoreDataEvent] {
        let request = NSFetchRequest<NotificareCoreDataEvent>(entityName: "NotificareCoreDataEvent")
        let result = try self.context.fetch(request)

        return result
    }


    func save() {
        if self.context.hasChanges {
            do {
                try self.context.save()
            } catch {
                Notificare.shared.logger.error("Failed to save CoreData changes.")
                Notificare.shared.logger.debug("\(error)")
            }
        } else {
            Notificare.shared.logger.verbose("Nothing to save.")
        }
    }
}
