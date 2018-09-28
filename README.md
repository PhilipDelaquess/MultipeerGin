#  Multipeer Gin Game

## Determine which peer is the master and which the slave.

- Generate a local UUID at startup. Advertise it in your connection info dictionary.
- When your browser detects a peer, remember its remote UUID.
- When the remote peer connects, note that it is connected.
- The above two things can happen in either order.
- When both have happened, compare local to remote UUIDs and be master or slave accordingly

## What is the difference, really, between master and slave?

Each peer can keep its own game state. Each can transition from one state to the next in response to
a command from whose turn it is.

The master shuffles the deck and chooses a dealer. That's all.
