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
    
    init (melds: [Group], deadwood: [Card]) {
        self.melds = melds
        self.deadwood = deadwood
        self.score = deadwood.map { $0.score } .reduce (0, +)
    }

    override var description: String {
        let strs = melds.map { $0.description } + deadwood.map { $0.abbreviation }
        return strs.joined(separator: " ")
    }
    
}
