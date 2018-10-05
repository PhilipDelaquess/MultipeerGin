//
//  Game.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 10/1/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import UIKit

class Game: NSObject {
    
    var deck: Deck?
    var discard: [Card]?
    var hand: Hand?
    var localPlayerState = PlayerState.awaitingOpponentArrival
    var peerPlayerState = PlayerState.awaitingOpponentArrival

    func initialize (deck: Deck, hand: Hand, asDealer: Bool) {
        self.deck = deck
        self.discard = [Card]()
        self.discard!.append(deck.dealOne())
        self.hand = hand
        self.localPlayerState = asDealer ? .awaitingOpponentAction : .poneInitialDraw
        self.peerPlayerState = asDealer ? .poneInitialDraw : .awaitingOpponentAction
    }
}
