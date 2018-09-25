//
//  CardTests.swift
//  MultipeerGinTests
//
//  Created by Philip Delaquess on 9/24/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import XCTest
@testable import MultipeerGin

class CardTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testByAbbreviation () {
        let aceOfSpades = Card.by(abbreviation: "AS")
        XCTAssert(aceOfSpades != nil)
        XCTAssert(aceOfSpades!.face == .ace)
        XCTAssert(aceOfSpades!.suit == .spades)
    }
    
    func testByBadAbbreviation () {
        let bogus = Card.by(abbreviation: "XXX")
        XCTAssert(bogus == nil)
    }
    
    func testBySuitAndFace () {
        let fourOfDiamonds = Card.by(suit: .diamonds, face: .four)
        XCTAssert(fourOfDiamonds.abbreviation == "4D")
    }
    
    func testOrdinals () {
        XCTAssert(Card.by(abbreviation: "AC")!.ordinal == 1)
        XCTAssert(Card.by(abbreviation: "8C")!.ordinal == 8)
        XCTAssert(Card.by(abbreviation: "JC")!.ordinal == 11)
        XCTAssert(Card.by(abbreviation: "KC")!.ordinal == 13)
    }
    
    func testScores () {
        XCTAssert(Card.by(abbreviation: "AC")!.score == 1)
        XCTAssert(Card.by(abbreviation: "8C")!.score == 8)
        XCTAssert(Card.by(abbreviation: "JC")!.score == 10)
        XCTAssert(Card.by(abbreviation: "KC")!.score == 10)
    }
    
}
