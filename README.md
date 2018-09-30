#  Multipeer Gin Game

## Determine which peer is the master and which the slave.

- Generate a local UUID at startup.
- When connected, send your own UUID.
- When you receive a UUID, become "connected" as master or slave

## What is the difference, really, between master and slave?

Each peer can keep its own game state. Each can transition from one state to the next in response to
a command from whose turn it is.

The master shuffles the deck and chooses a dealer. That's all.
