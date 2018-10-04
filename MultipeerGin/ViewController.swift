//
//  ViewController.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 2/3/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var service: ServiceManager?

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deckButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var noThanksButton: UIButton!
    @IBOutlet var handButtons: [UIButton]!
    
    var game: Game?

    override func viewDidLoad() {
        super.viewDidLoad()
        service = ServiceManager()
        service!.delegate = self
    }

    @IBAction func deckTapped(_ sender: UIButton) {
        NSLog("%@", "Deck")
    }
    
    @IBAction func discardTapped(_ sender: UIButton) {
        NSLog("%@", "Discard")
    }

    @IBAction func noThanksTapped(_ sender: UIButton) {
        NSLog("%@", "No Thanks")
    }
    
    @IBAction func handTapped(_ sender: UIButton) {
        NSLog("%@", "Card in slot \(sender.tag)")
    }
    
    private func displayGame () {
        if let g = self.game {
            deckButton.setTitle("\(g.deck.cards.count)", for: UIControlState.normal)
            populateButton(discardButton, withCard: g.discard[0])
            slotCardsIntoButtons(melding: g.hand.meldings[0])
            var status: String
            switch g.localPlayerState {
            case .awaitingOpponentAction:
                status = "Waiting for opponent..."
                noThanksButton.isHidden = true
            case .poneInitialDraw:
                status = "Opponent dealt. Tap the \(g.discard[0].unicode) if you want it."
                noThanksButton.isHidden = false
            default:
                status = "TODO"
                noThanksButton.isHidden = false
            }
            handButtons[10].isHidden = true
            statusLabel!.text = status
        }
    }
    
    private func slotCardsIntoButtons (melding: Melding) {
        for ix in 0 ..< 10 {
            populateButton(handButtons[ix], withCard: melding.cards[ix])
        }
    }
    
    private func populateButton (_ button: UIButton, withCard card: Card) {
        button.setTitle(card.unicode, for: UIControlState.normal)
        button.setTitleColor(card.suit == .hearts || card.suit == .diamonds ? UIColor.red : UIColor.black, for: UIControlState.normal)
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
            slotCardsIntoButtons(melding: myHand.meldings[0])
            service?.sendInitialGameState(deck: deck.cards, hand: oppHand)
            game = Game(deck: deck, hand: myHand, asDealer: true)
            displayGame()
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
        displayGame()
    }
}
