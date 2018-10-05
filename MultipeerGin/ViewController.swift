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
        game = Game()
        service = ServiceManager()
        service!.delegate = self

        statusLabel!.text = "Waiting for opponent to connect..."
        deckButton.isHidden = true
        discardButton.isHidden = true
        noThanksButton.isHidden = true
        for b in handButtons {
            b.isHidden = true
        }
    }

    // MARK: - user actions

    @IBAction func deckTapped(_ sender: UIButton) {
        NSLog("%@", "Deck")
    }

    @IBAction func discardTapped(_ sender: UIButton) {
        NSLog("%@", "Discard")
    }

    @IBAction func noThanksTapped(_ sender: UIButton) {
        if let g = game {
            if g.localPlayerState == .poneInitialDraw || g.localPlayerState == .dealerInitialDraw {
                g.peerPlayerState = g.localPlayerState == .poneInitialDraw ? .dealerInitialDraw : .poneSecondDraw
                g.localPlayerState = .awaitingOpponentAction
                let dict = ["payloadType" : "rejectInitial"]
                service!.send(dictionary: dict)
                noThanksButton.isHidden = true
                populateStatusLabel()
            }
        }
    }

    @IBAction func handTapped(_ sender: UIButton) {
        NSLog("%@", "Card in slot \(sender.tag)")
    }

    // MARK: - remote peer actions

    func createInitialGameState () {
        let deck = Deck()
        let oppHand = deck.dealTen()
        let myHand = Hand(cards: deck.dealTen())

        let dict = [
            "payloadType" : "initialGameState",
            "deck" : deck.cards.map { $0.abbreviation },
            "hand" : oppHand.map { $0.abbreviation }
        ] as [String : Any]
        service?.send(dictionary: dict)

        game!.initialize(deck: deck, hand: myHand, asDealer: true)

        deckButton.isHidden = false
        discardButton.isHidden = false
        for b in handButtons {
            if b.tag < 10 {
                b.isHidden = false
            }
        }
        populateDeckButton()
        populateDiscardButton()
        populateCardButtons()
        populateStatusLabel()
    }

    func sentInitialGameState (deckAbbrs: [String], handAbbrs: [String]) {
        let deck = Deck(withAbbrevs: deckAbbrs)
        let hand = Hand(cards: handAbbrs.map { Card.by(abbreviation: $0)! })

        game!.initialize(deck: deck, hand: hand, asDealer: false)

        deckButton.isHidden = false
        discardButton.isHidden = false
        noThanksButton.isHidden = false
        for b in handButtons {
            if b.tag < 10 {
                b.isHidden = false
            }
        }
        populateDeckButton()
        populateDiscardButton()
        populateCardButtons()
        populateStatusLabel()
    }

    func rejectedInitialDiscard () {
        if let g = game {
            if g.peerPlayerState == .poneInitialDraw {
                g.localPlayerState = .dealerInitialDraw
                noThanksButton.isHidden = false
            } else {
                g.localPlayerState = .poneSecondDraw
            }
            g.peerPlayerState = .awaitingOpponentAction
            populateStatusLabel()
        }
    }

    // MARK: - UI updaters

    private func populateDeckButton () {
        if let g = game {
            if let deck = g.deck {
                deckButton.setTitle("\(deck.cards.count)", for: UIControlState.normal)
            }
        }
    }

    private func populateDiscardButton () {
        if let g = game {
            if let discard = g.discard {
                if discard.isEmpty {
                    discardButton.setTitle(" ", for: UIControlState.normal)
                } else {
                    populateButton(discardButton, withCard: discard[0])
                }
            }
        }
    }

    private func populateCardButtons () {
        if let g = game {
            if let hand = g.hand {
                for ix in 0 ..< 10 {
                    populateButton(handButtons[ix], withCard: hand.meldings[0].cards[ix])
                }
            }
        }
    }

    private func populateStatusLabel () {
        if let g = game {
            var status: String
            switch g.localPlayerState {
            case .awaitingOpponentAction:
                switch g.peerPlayerState {
                case .poneInitialDraw:
                    status = "You dealt. Offering top discard to opponent..."
                case .dealerInitialDraw:
                    status = "Offering top discard to dealer..."
                case .poneSecondDraw:
                    status = "Opponent must draw from deck..."
                case .normalDraw:
                    status = "Waiting for opponent to draw..."
                default:
                    status = "Waiting for opponent to discard..."
                }
            case .poneInitialDraw:
                status = "Opponent dealt. Tap the \(g.discard![0].unicode) if you want it."
            case .dealerInitialDraw:
                status = "Opponent does not want the \(g.discard![0].unicode). Tap it if you want it."
            case .poneSecondDraw:
                status = "Dealer does not want it either. Tap the deck to draw."
            default:
                status = "TODO"
            }
            statusLabel!.text = status
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
        if master {
            createInitialGameState()
        } else {
            self.statusLabel!.text = "???"
        }
    }

    func disconnectedFromOpponent () {
        self.statusLabel!.text = "Shit! Came unconnected"
    }

    func receivedData (dictionary: [String : Any]) {
        let payloadType = dictionary["payloadType"] as! String
        if payloadType == "initialGameState" {
            let deckAbbrs = dictionary["deck"] as! [String]
            let handAbbrs = dictionary["hand"] as! [String]
            sentInitialGameState(deckAbbrs: deckAbbrs, handAbbrs: handAbbrs)
        } else if payloadType == "rejectInitial" {
            rejectedInitialDiscard()
        }
    }
}
