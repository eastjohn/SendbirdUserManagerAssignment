//
//  SerialQueue.swift
//
//
//  Created by 김요한 on 9/1/24.
//

import Foundation

struct SerialQueue {
    private static let queueNameKey = DispatchSpecificKey<String>()
    private let queue: DispatchQueue

    init(label: String, qos: DispatchQoS = .userInitiated) {
        let queue = DispatchQueue(label: label, qos: qos)
        queue.setSpecific(key: Self.queueNameKey, value: label)
        self.queue = queue
    }

    func sync(execute: () -> Void) {
        if isCurrentRunQueue() {
            execute()
        } else {
            queue.sync {
                execute()
            }
        }
    }

    func run(execute: @escaping () -> Void) {
        if isCurrentRunQueue() {
            execute()
        } else {
            queue.async {
                execute()
            }
        }
    }

    func asyncAfter(deadline: DispatchTime, execute: @escaping () -> Void) {
        queue.asyncAfter(deadline: deadline, execute: execute)
    }

    func preconditionOnQueue() {
        dispatchPrecondition(condition: .onQueue(queue))
    }

    func preconditionNotOnQueue() {
        dispatchPrecondition(condition: .notOnQueue(queue))
    }
}

extension SerialQueue {
    private func isCurrentRunQueue() -> Bool {
        guard let specificValue = queue.getSpecific(key: Self.queueNameKey) else { return false }
        return DispatchQueue.getSpecific(key: Self.queueNameKey) == specificValue
    }
}
