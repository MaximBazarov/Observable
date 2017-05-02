//
// Created by Maksim Bazarov on 29.04.17.
// Copyright (c) 2017 Maksim Bazarov. All rights reserved.
//

import Foundation

public typealias CancelSubscription = (Void) -> (Void)

public final class Observable<T: Comparable> {
    
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
    
    public func subscribe(to conditionValue: T,callback: @escaping (T) -> Void) -> CancelSubscription {
        let observer = Observer(handler: callback)
        observer.conditionValue = conditionValue
        lock.async {
            self.observers.add(observer)
        }
        return { [weak self] in self?.removeObserver(observer: observer) }
    }
    
    
    /// Value
    private var _value: T
    var value: T {
        get {
            return lock.sync {
                return self._value
            }
        }
        
        set {
            let observers: [Observer] = lock.sync { () -> [Observer] in
                self._value = newValue
                return self.observers.allObjects
            }
            
            for observer in observers {
                
                if let conditionValue = observer.conditionValue, newValue == conditionValue {
                    observer.handler(newValue)
                }
                
                if observer.conditionValue == nil {
                    observer.handler(newValue)
                }
            }
        }
        
    }
    
    public init(_ value: T) {
        self._value = value
    }
    
    // MARK: Private stuff
    typealias Handler = (T) -> Void
    
    private final class Observer {
        let handler: Handler
        var conditionValue: T?
        init(handler: @escaping Handler) {
            self.handler = handler
        }
    }
    
    private let lock = DispatchQueue(label: "Observable.lockQueue")
    
    private var observers = NSHashTable<Observer>()
    
    private func removeObserver(observer: Observer) {
        lock.async { [weak self] in
            self?.observers.remove(observer)
        }
    }
}
