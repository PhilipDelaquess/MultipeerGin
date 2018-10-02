//
//  Deck.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 9/30/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import UIKit

class Deck: NSObject {
    
    var cards: [Card]
    
    override init () {
        cards = Card.getAll()
        super.init()
    }
    
    init (withAbbrevs abbrevs: [String]) {
        cards = abbrevs.map { Card.by(abbreviation: $0)! }
    }
    
    func dealTen () -> [Card] {
        var rv = [Card]()
        for _ in 0..<10 {
            rv.append(cards.removeFirst())
        }
        return rv
    }
    
    func dealOne () -> Card {
        return cards.removeFirst()
    }

}
