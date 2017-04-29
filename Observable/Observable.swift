//
// Created by Maksim Bazarov on 29.04.17.
// Copyright (c) 2017 Maksim Bazarov. All rights reserved.
//

import Foundation

public typealias CancelSubscription = (Void) -> (Void)

public final class Observable<T> {

    /// Subscribe to value changes
    ///
    /// - Parameter callback: runs every value changes
    /// - Returns: unsubscribe function 
    @discardableResult
    public func subscribe(callback: @escaping (T) -> Void) -> CancelSubscription {
        let observer = Observer(handler: callback)
        lock.async {
            self.observers.add(observer)
        }
        return { [weak self] in self?.removeObserver(observer: observer) }
    }
    
    /// Value
    var value: T {
        didSet {
            var newValue: T?
            lock.sync {
                newValue = value
            }
            
            for o in observers.allObjects {
                o.handler(newValue!)
            }
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    // MARK: Private stuff
    private final class Observer {
        let handler: Handler
        init(handler: @escaping Handler) {
            self.handler = handler
        }
    }
    
    typealias Handler = (T) -> Void
    
    private let lock = DispatchQueue(label: "Observable.lockQueue")
    private var observers = NSHashTable<Observer>()
    
    private func removeObserver(observer: Observer) {
        lock.async { [weak self] in
            self?.observers.remove(observer)
        }
    }
    
}
