//
//  ObservableThreadSafetyTests.swift
//  Observable
//
//  Created by Maksim Bazarov on 02.05.17.
//  Copyright © 2017 Maksim Bazarov. All rights reserved.
//

import XCTest
@testable import Observable

class ObservableThreadTests: XCTestCase {
    
    // MARK: Atomic helper
    
   
    
    // MARK: Tests
    
    func testChangeValue101TimesOnRandomThread_SumObservedShouldBeEqualSumOfSended() {
        let sut = Observable<Int>(0)
        let lock = DispatchQueue(label: "ObservableTest.lockQueue")
        var result = 0
        var expected = 0
        (0...100).forEach { (i) in
            expected += i
        }
        
        let _ = sut.subscribe { v in
            lock.async {
                result += v
            }
        }
        
        DispatchQueue.concurrentPerform(iterations: 101) { iteration in
            sut.value = iteration
        }
        
        lock.sync {
            
            print(expected)
            XCTAssertEqual(result, expected)
        }
    }
    
    func testChangeValuesOnRandomThread_OrderObservedShouldBeSameAsSent() {
        let sut = Observable<Int>(0)
        let lock = DispatchQueue(label: "ObservableTest.lockQueue")
        var result = [Int]()
        var expected = [Int]()
        
        let _ = sut.subscribe { v in
            lock.async {
                result.append(v)
            }
        }
        
        DispatchQueue.concurrentPerform(iterations: 1000) { iteration in
            lock.sync {
                sut.value = iteration
                expected.append(iteration)
            }
        }
        
        lock.sync {
            XCTAssertEqual(result, expected)
        }
    }
    
    func disabledTestIncrementValueOnRandomThread_ValueShouldBeIncremented() {
        let sut = Observable<Int>(0)
        var expected = 0
        (0...1000).forEach { (i) in
            expected += i
        }
        
        let lock = DispatchQueue(label: "ObservableTest.lockQueue")
        lock.sync {
            DispatchQueue.concurrentPerform(iterations: 1001) { iteration in
                sut.value = sut.value + iteration
                print("\(iteration): \(sut.value)")
            }
        }
        
        
        XCTAssertEqual(sut.value, expected)
    }
    
    func disabledTestRecursiveValueUpdate() {
        let sut = Observable<Int>(0)
        
        let expected = 10
        var actual = 0
        
        _ = sut.subscribe { v in
            if v == 1 {
                sut.value = 10
            }
        }
        _ = sut.subscribe { v in
            actual = v
        }
        
        sut.value = 1
        
        XCTAssertEqual(actual, expected)
    }

}
