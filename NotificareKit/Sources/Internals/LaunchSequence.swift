//
// Copyright (c) 2022 Notificare. All rights reserved.
//

import Foundation

internal class LaunchSequence {
    internal typealias PerformBlock = (
        _ module: NotificareInternals.Module,
        _ instance: NotificareModule.Type,
        _ completion: @escaping NotificareCallback<Void>
    ) -> Void

    private var modules: [NotificareInternals.Module]

    init(_ modules: [NotificareInternals.Module]) {
        self.modules = modules
    }

    func run(onEach perform: @escaping PerformBlock, onDone: @escaping NotificareCallback<Void>) {
        guard !modules.isEmpty else {
            onDone(.success(()))
            return
        }

        let module = modules.remove(at: 0)

        guard let instance = module.instance else {
            // Skip unavailable modules.
            run(onEach: perform, onDone: onDone)
            return
        }

        perform(module, instance) { result in
            if case let .failure(error) = result {
                // Short circuit the flow from processing additional modules.
                onDone(.failure(error))
                return
            }

            self.run(onEach: perform, onDone: onDone)
        }
    }
}
