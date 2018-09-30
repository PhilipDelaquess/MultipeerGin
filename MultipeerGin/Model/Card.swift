//
//  Card.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 9/23/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import Foundation

class Card: NSObject {
    let suit: Suit
    let face: Face
    let abbreviation: String
    let ordinal: Int
    let score: Int
    
    // Return the Card with the given abbreviation, if any
    static func by (abbreviation: String) -> Card? {
        return byAbbreviation[abbreviation]
    }

    // Return the Card with the given suit and face
    static func by (suit: Suit, face: Face) -> Card {
        return by(abbreviation: face.rawValue + String(suit.rawValue))!
    }
    
    // Return a list of all Cards
    static func getAll () -> [Card] {
        return shuffle(cards: allCards)
    }
    
    static func shuffle (cards: [Card]) -> [Card] {
        if cards.count < 2 {
            return cards
        }
        var rv = [Card](cards)
        for i in 0..<(rv.count - 1) {
            let j = Int(arc4random_uniform(UInt32(rv.count - i))) + i
            let x = rv[i]
            rv[i] = rv[j]
            rv[j] = x
        }
        return rv
    }
    
    
    static let faceComp = { (c1: Card, c2: Card) -> Bool in
        if c1.ordinal != c2.ordinal {
            return c1.ordinal < c2.ordinal
        } else {
            return c1.suit.rawValue < c2.suit.rawValue
        }
    }
    
    static let suitComp = { (c1: Card, c2: Card) -> Bool in
        if c1.suit != c2.suit {
            return c1.suit.rawValue < c2.suit.rawValue
        } else {
            return c1.ordinal < c2.ordinal
        }
    }
    
    private static let allCards = Suit.allSuits.map { suit in
        Face.allFaces.enumerated().map { Card(suit: suit, face: $0.element, ordinal: $0.offset + 1) }
    }.flatMap { $0 }
    
    private static let byAbbreviation = allCards.reduce([String : Card]()) {(result, card) in
        result.merging([card.abbreviation : card]) {(current, _) in current}
    }
    
    private init (suit: Suit, face: Face, ordinal: Int) {
        self.suit = suit
        self.face = face
        
        self.abbreviation = face.rawValue + String(suit.rawValue)
        self.ordinal = ordinal
        self.score = min(self.ordinal, 10)
    }
}
