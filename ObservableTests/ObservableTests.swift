//
//  ObservableTests.swift
//  ObservableTests
//
//  Created by Maksim Bazarov on 29.04.17.
//  Copyright © 2017 Maksim Bazarov. All rights reserved.
//

import XCTest
@testable import Observable

class ObservableTests: XCTestCase {
    
    func testAdd10ObserversAndChangeValue_ShouldBe10Values() {
        let count = 10
        let sut = Observable<String>("sut")
        var result = [String]()
        var unsubscribeTable = [Int: CancelSubscription]()
        (1...count).forEach({ (index) in
            let unsubscribe = sut.subscribe { value in
                result.append(value)
            }
            unsubscribeTable[index] = unsubscribe
        })
        
        sut.value = "test"
        
        XCTAssertEqual(result.count, count)
    }
    
    func testAdd10ObserversAndChangeValue10Times_ShouldBe100Values() {
        let sut = Observable<String>("sut")
        var result = [String]()
        var unsubscribeTable = [Int: CancelSubscription]()
        (1...10).forEach({ (index) in
            let unsubscribe = sut.subscribe { value in
                result.append(value)
            }
            unsubscribeTable[index] = unsubscribe
        })
        
        (1...10).forEach({ (index) in
            sut.value = "\(index)"
        })
        
        
        XCTAssertEqual(result.count, 100)
    }
    
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
    
    func testChangeValuesOnRandomThread_OrderObservedShouldBeSameAsSended() {
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
    
    func testChangeValue_ObservableValueShouldBeEqualNewValue() {
        let sut = Observable<Int>(0)
        sut.value = 10
        XCTAssertEqual(sut.value, 10)
    }
    
}
