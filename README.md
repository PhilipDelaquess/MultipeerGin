#  Multipeer Gin Game

Add alert box that asks "Do you want to knock with N points of deadwood?"

Factor out the discard code from the button handler
Create UIAlertController with two UIAlertAction, each with its own handler lambda
One calls refactored code with knock = false, the other with knock = true
Button handler removes card from hand, so now we know the hand's deadwood points.
Action handlers perform the state changes, transmit to peer, and update UI
We could now be in .awaitingOpponentAction or in .acknowledgeDeal (maybe in a different view controller)


