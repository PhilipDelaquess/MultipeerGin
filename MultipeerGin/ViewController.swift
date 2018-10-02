//
//  ViewController.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 2/3/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    let service = ServiceManager();
    
    var game: Game?

    override func viewDidLoad() {
        super.viewDidLoad()
        service.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : ServiceManagerDelegate {
    func connectedToOpponent (asMaster master : Bool) {
        self.statusLabel!.text = "Connected with role \(master ? "master" : "slave"). Yay!"
        if master {
            let deck = Deck()
            let oppHand = deck.dealTen()
            let myHand = Hand(cards: deck.dealTen())
            service.sendInitialGameState(deck: deck.cards, hand: oppHand)
            game = Game(deck: deck, hand: myHand, asDealer: true)
            self.statusLabel!.text = game!.discard[0].abbreviation
        } else {
            self.statusLabel!.text = "???"
        }
    }

    func disconnectedFromOpponent () {
        self.statusLabel!.text = "Shit! Came unconnected"
    }

    func receivedInitialGameState (deckAbbrs: [String], handAbbrs: [String]) {
        let deck = Deck(withAbbrevs: deckAbbrs)
        let hand = Hand(cards: handAbbrs.map { Card.by(abbreviation: $0)! })
        game = Game(deck: deck, hand: hand, asDealer: false)
        self.statusLabel!.text = game!.discard[0].abbreviation
    }
}
