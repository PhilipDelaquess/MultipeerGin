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

    var buttonContents = [Card]()

    var game: Game?

    private let PayloadType = "payloadType"
    private let InitialGameState = "initialGameState"
    private let InitialDeck = "deck"
    private let InitialHand = "hand"
    private let RejectInitial = "rejectInitial"
    private let DrawDeck = "drawDeck"
    private let DrawDiscard = "drawDiscard"
    private let Discard = "discard"
    private let DiscardAbbrev = "abbrev"

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
        if let g = game {
            if g.localPlayerState == .poneSecondDraw || g.localPlayerState == .normalDraw {
                g.localPlayerState = .discardOrKnock
                let dict = [PayloadType : DrawDeck]
                service!.send(dictionary: dict)
                let c = g.deck!.cards.removeFirst()
                g.hand!.draw(card: c)
                populateDeckButton()
                populateCardButtons(withDraw: c)
                statusLabel!.text = "Tap the card you want to discard."
            }
        }
    }

    @IBAction func discardTapped(_ sender: UIButton) {
        if let g = game {
            if g.localPlayerState == .poneInitialDraw || g.localPlayerState == .dealerInitialDraw || g.localPlayerState == .normalDraw {
                if g.discard!.count > 0 {
                    g.localPlayerState = .discardOrKnock
                    let dict = [PayloadType : DrawDiscard]
                    service!.send(dictionary: dict)
                    let c = g.discard!.removeFirst()
                    g.hand!.draw(card: c)
                    noThanksButton.isHidden = true
                    populateDiscardButton()
                    populateCardButtons(withDraw: c)
                    statusLabel!.text = "Tap the card you want to discard."
                }
            }
        }
    }

    @IBAction func noThanksTapped(_ sender: UIButton) {
        if let g = game {
            if g.localPlayerState == .poneInitialDraw || g.localPlayerState == .dealerInitialDraw {
                g.peerPlayerState = g.localPlayerState == .poneInitialDraw ? .dealerInitialDraw : .poneSecondDraw
                g.localPlayerState = .awaitingOpponentAction
                let dict = [PayloadType : RejectInitial]
                service!.send(dictionary: dict)
                noThanksButton.isHidden = true
                statusLabel!.text = g.peerPlayerState == .dealerInitialDraw
                    ? "Offering initial discard to dealer..."
                    : "Opponent must draw from deck..."
            }
        }
    }

    @IBAction func handTapped(_ sender: UIButton) {
        if let g = game {
            if g.localPlayerState == .discardOrKnock {
                g.localPlayerState = .awaitingOpponentAction
                g.peerPlayerState = .normalDraw
                let c = buttonContents[sender.tag]
                g.hand!.discard(card: c)
                g.discard!.insert(c, at: 0)
                let dict = [
                    PayloadType : Discard,
                    DiscardAbbrev : c.abbreviation
                ]
                service!.send(dictionary: dict)
                populateDiscardButton()
                populateCardButtons()
                statusLabel!.text = "Waiting for opponent to draw..."
            }
        }
    }

    // MARK: - remote peer actions

    func createInitialGameState () {
        let deck = Deck()
        let oppHand = deck.dealTen()
        let myHand = Hand(cards: deck.dealTen())

        let dict = [
            PayloadType : InitialGameState,
            InitialDeck : deck.cards.map { $0.abbreviation },
            InitialHand : oppHand.map { $0.abbreviation }
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
        statusLabel!.text = "You dealt. Offering top discard to opponent..."
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
        statusLabel!.text = "Opponent dealt. Tap top discard if you want it."
    }

    func rejectedInitialDiscard () {
        if let g = game {
            if g.peerPlayerState == .poneInitialDraw {
                g.localPlayerState = .dealerInitialDraw
                noThanksButton.isHidden = false
                statusLabel!.text = "Opponent does not want top discard. Tap it if you want it."
            } else {
                g.localPlayerState = .poneSecondDraw
                statusLabel!.text = "Dealer doesn't want it either. Tap the deck to draw."
            }
            g.peerPlayerState = .awaitingOpponentAction
        }
    }

    func drewTopDiscard () {
        if let g = game {
            g.peerPlayerState = .discardOrKnock
            g.discard!.removeFirst()
            populateDiscardButton()
            statusLabel!.text = "Waiting for opponent to discard..."
        }
    }

    func drewDeck () {
        if let g = game {
            g.peerPlayerState = .discardOrKnock
            g.deck!.cards.removeFirst()
            populateDeckButton()
            statusLabel!.text = "Waiting for opponent to discard..."
        }
    }

    func discarded (card: Card) {
        if let g = game {
            g.localPlayerState = .normalDraw
            g.peerPlayerState = .awaitingOpponentAction
            g.discard!.insert(card, at: 0)
            populateDiscardButton()
            statusLabel!.text = "Your turn. Tap deck or discard pile to draw."
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
                    discardButton.setTitle("--", for: UIControlState.normal)
                } else {
                    populateCardButton(discardButton, withCard: discard[0], asRecent: false)
                }
            }
        }
    }

    private func populateCardButtons (withDraw card: Card? = nil) {
        if let g = game {
            if let hand = g.hand {
                buttonContents.removeAll()
                for ix in 0 ..< hand.cards.count {
                    let c = hand.meldings[0].cards[ix]
                    populateCardButton(handButtons[ix], withCard: c, asRecent: card == c)
                    buttonContents.append(c)
                }
                handButtons[10].isHidden = hand.cards.count < 11
            }
        }
    }

    private func populateCardButton (_ button: UIButton, withCard card: Card, asRecent recent: Bool) {
        button.setTitle(card.unicode, for: UIControlState.normal)
        button.setTitleColor(card.suit == .hearts || card.suit == .diamonds ? UIColor.red : UIColor.black, for: UIControlState.normal)
        button.backgroundColor = recent ? UIColor.yellow : UIColor.white
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
        let payloadType = dictionary[PayloadType] as! String
        if payloadType == InitialGameState {
            let deckAbbrs = dictionary[InitialDeck] as! [String]
            let handAbbrs = dictionary[InitialHand] as! [String]
            sentInitialGameState(deckAbbrs: deckAbbrs, handAbbrs: handAbbrs)
        } else if payloadType == RejectInitial {
            rejectedInitialDiscard()
        } else if payloadType == DrawDiscard {
            drewTopDiscard()
        } else if payloadType == DrawDeck {
            drewDeck()
        } else if payloadType == Discard {
            discarded(card: Card.by(abbreviation: dictionary[DiscardAbbrev] as! String)!)
        }
    }
}
