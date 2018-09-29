//
//  HandTests.swift
//  MultipeerGinTests
//
//  Created by Philip Delaquess on 9/28/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import XCTest
@testable import MultipeerGin

class HandTests: XCTestCase {
    
    func testGarbage () {
        let card = makeHand(fromAbbrevs: ["AS", "5D", "JD", "3S", "QH", "AD", "9H", "4S"])
        XCTAssert(card.meldings.count == 1)
        XCTAssert(card.meldings[0].description == "AD AS 3S 4S 5D 9H JD QH")
    }
    
    func testOneFaceMeld () {
        let card = makeHand(fromAbbrevs: ["AS", "5D", "JD", "3S", "5H", "QH", "AD", "9H", "4S", "5C"])
        XCTAssert(card.meldings.count == 1)
        XCTAssert(card.meldings[0].description == "[5C 5D 5H] AD AS 3S 4S 9H JD QH")
    }
    
    func testOneSuitMeld () {
        let card = makeHand(fromAbbrevs: ["QH", "JH", "KS", "3C", "10H"])
        XCTAssert(card.meldings.count == 1)
        XCTAssert(card.meldings[0].description == "[10H JH QH] 3C KS")
    }
    
    func testTwoDistinctMelds () {
        let card = makeHand(fromAbbrevs: ["3S", "4S", "KD", "5S", "8S", "8H", "8C"])
        XCTAssert(card.meldings.count == 1)
        XCTAssert(card.meldings[0].description == "[3S 4S 5S] [8C 8H 8S] KD")
    }
    
    func testOverlappingMelds () {
        let card = makeHand(fromAbbrevs: ["3S", "4S", "5S", "5H", "5D", "8C", "10C", "JS"])
        XCTAssert(card.meldings.count == 2)
        XCTAssert(card.meldings[0].description == "[5D 5H 5S] 3S 4S 8C 10C JS")
        XCTAssert(card.meldings[0].score == 35)
        XCTAssert(card.meldings[1].description == "[3S 4S 5S] 5D 5H 8C 10C JS")
        XCTAssert(card.meldings[1].score == 38)
    }
    
    private func makeHand (fromAbbrevs abbrevs: [String]) -> Hand {
        return Hand(cards: abbrevs.map { Card.by(abbreviation: $0)! })
    }
    
}
