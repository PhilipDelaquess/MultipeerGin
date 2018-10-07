//
//  Hand.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 9/27/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

import Foundation

class Hand: NSObject {
    var cards: [Card]
    var meldings: [Melding]

    init (cards: [Card]) {
        self.cards = cards.sorted(by: Card.faceComp)
        self.meldings = Array()
        super.init()

        findMeldings()
    }

    func draw (card: Card) {
        cards.append(card)
        findMeldings()
    }

    func discard (card: Card) {
        cards = cards.filter { $0 != card }
        findMeldings()
    }

    private func findMeldings () {
        var cards = Array(self.cards)
        var melds = [Group]()
        self.meldings.removeAll()
        findMeldingsAux(&cards, &melds)
        self.meldings.sort(by: { $0.score < $1.score })
    }

    // Recursive function with side effects
    //
    // cards: the cards to try to group into melds, not including cards already melded
    // melds: a list that may already contain some melds, made from cards not in cards:
    // When the recursion "bottoms out," i.e., no overlapping melds are possible,
    // then create a Melding from the melds: and treat the cards: as deadwood.
    // But if any cards could be in more than one meld, then recurse on each of those
    // melds, provisionally adding the group to groups: and removing the cards from cards:
    //
    private func findMeldingsAux (_ cards: inout [Card], _ melds: inout [Group]) {
        // find all possible melds, regardless of overlap
        cards = cards.sorted(by: Card.suitComp)
        var localMelds = findSuitMelds(cards)
        cards = cards.sorted(by: Card.faceComp)
        localMelds += findFaceMelds(cards)

        // map each card to a list of the melds it belongs to
        var meldsByCard = [Card : [Group]]()
        for c in cards {
            meldsByCard[c] = [Group]()
        }
        for lm in localMelds {
            for c in lm.cards {
                meldsByCard[c]!.append(lm)
            }
        }

        // bad cards, or badz, are cards that belong to more than one meld
        let badz = Set(cards.filter() { meldsByCard[$0]!.count > 1 })

        // clean melds have no bad cards; dirty melds have at least one
        var cleanMelds = [Group]()
        var dirtyMelds = [Group]()
        for lm in localMelds {
            var bad = false
            for c in lm.cards {
                if badz.contains(c) {
                    bad = true
                }
            }
            if bad {
                dirtyMelds.append(lm)
            } else {
                cleanMelds.append(lm)
            }
        }

        // add clean melds to our output, and eliminate their cards from further consideration
        for cm in cleanMelds {
            melds.append(cm)
            cards = removeCards(inGroup: cm, fromArray: cards)
        }

        if dirtyMelds.isEmpty {
            // recursion has bottomed out -- melds seen so far plus cards left over make a melding
            meldings.append(Melding(melds: melds, deadwood: cards))
        } else {
            // recurse on all (both) of the melds some bad card belongs to
            let bad = badz.first!
            for m in meldsByCard[bad]! {
                var melds2 = [Group](melds)
                melds2.append(m)
                var cards2 = removeCards(inGroup: m, fromArray: cards)
                findMeldingsAux(&cards2, &melds2)
            }
        }
    }

    private func findSuitMelds (_ cards: [Card]) -> [Group] {
        var rv = [Group]()
        var i = 0
        while i < cards.count {
            var crdz = [Card]()
            crdz.append(cards[i])
            let suit = cards[i].suit
            var ord = cards[i].ordinal
            var j = i + 1
            while j < cards.count && cards[j].suit == suit && cards[j].ordinal == ord + 1 {
                crdz.append(cards[j])
                ord += 1
                j += 1
            }
            if crdz.count >= 3 {
                rv.append(Group(cards: crdz, faceGroup: false))
            }
            i += 1
        }
        return rv
    }

    private func findFaceMelds (_ cards: [Card]) -> [Group] {
        var rv = [Group]()
        var i = 0
        while i < cards.count {
            var crdz = [Card]()
            crdz.append(cards[i])
            let face = cards[i].face
            var j = i + 1
            while j < cards.count && cards[j].face == face {
                crdz.append(cards[j])
                j += 1
            }
            if crdz.count >= 3 {
                rv.append(Group(cards: crdz, faceGroup: true))
            }
            i = j
        }
        return rv
    }

    private func removeCards (inGroup group: Group, fromArray cards: [Card]) -> [Card] {
        let crdz = Set(group.cards)
        return cards.filter() { !crdz.contains($0) }
    }
}
