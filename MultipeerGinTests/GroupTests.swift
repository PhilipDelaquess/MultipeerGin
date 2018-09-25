//
//  GroupTests.swift
//  MultipeerGinTests
//
//  Created by Philip Delaquess on 9/24/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import XCTest
@testable import MultipeerGin

class GroupTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFaceGroup () {
        let cards = [Card.by(abbreviation: "8S")!, Card.by(abbreviation: "8C")!]
        let group = Group(cards: cards, faceGroup: true)
        let helpers = group.getHelpers()
        
        XCTAssert(helpers.count == 2)
        XCTAssert(helpers.contains(Card.by(abbreviation: "8D")!))
        XCTAssert(helpers.contains(Card.by(abbreviation: "8H")!))
    }

    func testFaceGroup2 () {
        let cards = [
            Card.by(abbreviation: "8S")!,
            Card.by(abbreviation: "8C")!,
            Card.by(abbreviation: "8D")!
        ]
        let group = Group(cards: cards, faceGroup: true)
        let helpers = group.getHelpers()
        
        XCTAssert(helpers.count == 1)
        XCTAssert(helpers.contains(Card.by(abbreviation: "8H")!))
    }
    
    func testSuitGroup () {
        let cards = [Card.by(abbreviation: "AS")!, Card.by(abbreviation: "2S")!]
        let group = Group(cards: cards, faceGroup: false)
        let helpers = group.getHelpers()

        XCTAssert(helpers.count == 1)
        XCTAssert(helpers.contains(Card.by(abbreviation: "3S")!))
    }

    func testSuitGroup2 () {
        let cards = [Card.by(abbreviation: "QS")!, Card.by(abbreviation: "KS")!]
        let group = Group(cards: cards, faceGroup: false)
        let helpers = group.getHelpers()
        
        XCTAssert(helpers.count == 1)
        XCTAssert(helpers.contains(Card.by(abbreviation: "JS")!))
    }
    
    func testSuitGroup3 () {
        let cards = [Card.by(abbreviation: "6S")!, Card.by(abbreviation: "7S")!]
        let group = Group(cards: cards, faceGroup: false)
        let helpers = group.getHelpers()
        
        XCTAssert(helpers.count == 2)
        XCTAssert(helpers.contains(Card.by(abbreviation: "5S")!))
        XCTAssert(helpers.contains(Card.by(abbreviation: "8S")!))
    }
    
    func testSuitGroup4 () {
        let cards = [Card.by(abbreviation: "5S")!, Card.by(abbreviation: "7S")!]
        let group = Group(cards: cards, faceGroup: false)
        let helpers = group.getHelpers()
        
        XCTAssert(helpers.count == 1)
        XCTAssert(helpers.contains(Card.by(abbreviation: "6S")!))
    }
}
