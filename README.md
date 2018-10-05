#  Multipeer Gin Game

Need to acheive sanity with respect to game state changes.

When we're waiting for opponent, our UI is inactive.
The only thing we care about is data arriving to tell us that the
opponent made a state change.

Question: Should that message contain both peers' new states already calculated?

We have a Game "thing". UI actions tell the game to A) change its state and B) send notice to our peer.

The ServiceManager knows how to send and receive dictionary data.
It informs its delegate about data receipt on the main thread.

But the Game is what knows the dictionary contents and protocol.
Don't let ServiceManager know about that stuff.

USUALLY, we have
my state is .normalDraw
peer state is .awaitingOppenentAction
deck and discard buttons are active
hitting either draws a card
puts me in .discardOrKnock
leaves my opponent in .awaiting
but I tell peer which pile I drew from

BUT FIRST we have
my state is poneInitialDraw, or dealerInitialDraw, orPoneSecondDraw
these are just like normalDraw except
they limit which pile may be drawn from
they may present a no thanks button

tell Game: draw from this or that pile
send to peer
delegate message: peer drew from this or that pile

Game public methods called by UI actions
- createInitialGameState() - called when connected as master
- noThanks()
- drawFromDeck()
- drawFromDiscard()
- discard()
They change my state, opponent state, deck, discard pile, and my hand
And they send notice to peer

Game data handlers called by ServiceManager delegate method that gets a dictionary
parses it out, calls one of these:
- peerSentInitialGameState()
- peerSaidNoThanks()
- peerDrewFromDeck()
- peerDrawFromDiscard()
- peerDiscarded()

There is always a Game
both states start as .awaitingOpponentArrival
and it does not yet have a deck, discard, or hand

when view loads, create this Game and set initial UI mostly invisible
when connected as master, or receiving initial state as slave,
populate the deck, discard, and hand
make appropriate UI parts visible
