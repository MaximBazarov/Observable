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
    
    func testSendValue100TimesOnRandomThread_SumShouldBe100xValue() {
        let sut = Observable<Int>(8)
        let lock = DispatchQueue(label: "ObservableTest.lockQueue")
        var result = 0
    
        let _ = sut.subscribe { v in
            lock.async {
                result += v
            }
        }
    
        
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            sut.value = 2
        }
        
        
        lock.async {
            XCTAssert(result == 200)
        }
    }
    
}
