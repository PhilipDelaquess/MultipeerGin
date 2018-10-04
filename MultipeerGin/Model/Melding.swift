//
//  Melding.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 9/27/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import Foundation

class Melding: NSObject {
    
    let melds: [Group]
    let deadwood: [Card]
    let score: Int
    let cards: [Card] // melds and deadwood in display order
    
    init (melds: [Group], deadwood: [Card]) {
        self.melds = melds
        self.deadwood = deadwood
        self.score = deadwood.map { $0.score } .reduce (0, +)
        var crdz = [Card]()
        for m in melds {
            for c in m.cards {
                crdz.append(c)
            }
        }
        for c in deadwood {
            crdz.append(c)
        }
        cards = Array(crdz)
    }

    override var description: String {
        let strs = melds.map { $0.description } + deadwood.map { $0.abbreviation }
        return strs.joined(separator: " ")
    }
    
}
