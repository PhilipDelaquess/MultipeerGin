//
//  Group.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 9/24/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//
// A Group is an array of Cards that either have the same Face
// or are adjacent in the same Suit. If there are three or more Cards,
// they constitute a meld. If there are only two, they constitute an almost.

import Foundation

class Group : NSObject {
    let cards: [Card]
    let isFaceGroup: Bool
    
    init (cards: [Card], faceGroup: Bool) {
        self.cards = Array(cards)
        self.isFaceGroup = faceGroup
    }
    
    func getHelpers () -> Set<Card> {
        return isFaceGroup ? getSameFaceHelpers() : getSameSuitHelpers()
    }
    
    private func getSameFaceHelpers () -> Set<Card> {
        let face = cards[0].face
        let suits = Set(cards.map() { $0.suit })
        return Set(
            Suit.allSuits
                .filter() { !suits.contains($0) }
                .map() { Card.by(suit: $0, face: face) }
        )
    }
    
    private func getSameSuitHelpers () -> Set<Card> {
        var rv = Set<Card>()
        let suit = cards[0].suit
        let lowOrdinal = cards[0].ordinal
        if cards[1].ordinal - lowOrdinal == 1 {
            // two or more adjacent cards
            if lowOrdinal > 1 {
                rv.insert(Card.by(suit: suit, face: Face.allFaces[lowOrdinal - 2]))
            }
            let highOrdinal = cards.last!.ordinal
            if highOrdinal < 13 {
                rv.insert(Card.by(suit: suit, face: Face.allFaces[highOrdinal]))
            }
        } else {
            // filling an inside straight
            rv.insert(Card.by(suit: suit, face: Face.allFaces[lowOrdinal]))
        }
        return rv
    }
}

