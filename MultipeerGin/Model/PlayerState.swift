//
//  PlayerState.swift
//  MultipeerGin
//
//  Created by Philip Delaquess on 10/1/18.
//  Copyright © 2018 Philip Delaquess. All rights reserved.
//

enum PlayerState {
    
    case awaitingOpponentArrival
    case awaitingOpponentAction
    case poneInitialDraw
    case dealerInitialDraw
    case poneSecondDraw
    case normalDraw
    case discardOrKnock
    case acknowledgeDeal

}
