//
//  Concentration.swift
//  concentration
//
//  Created by Vlad Md Golam on 26.02.2018.
//  Copyright © 2018 Vlad Md Golam. All rights reserved.
//

import Foundation

struct Concentration
{
 
    // TODO: write the best score ever into file
    // change the icon
    
    private(set) var cards = [Card]()
    var isWon: Bool {
        return cards.indices.filter( { cards[$0].isMatched } ).count == cards.count
    }
    private var seenCards = Set<Int>()
    
    private(set) var scoreCount = 0
    private(set) var flipCount = 0
    
    init(numberOfPairsOfCards: Int) {
        assert(numberOfPairsOfCards > 0, "Concentration.init(at: \(index)): you must have at least one pair of cards")
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        for _ in cards.indices {
            cards.sort(by: {(_,_) in arc4random() < arc4random()})
        }
    }
    
    private struct Points {
        static let matchBonus = 20
        static let missMatchPenalty = 4
        static let maxTimePenalty = 4
    }
    
    var lastClick: Date?
    var timePenalty:Int {
        return min(lastClick?.sinceNow ?? 0, Points.maxTimePenalty)
    }

    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            return cards.indices.filter( { cards[$0].isFaceUp } ).oneAndOnly
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    
    var shouldTurnCards: Bool {
        return cards.filter( { $0.isFaceUp } ).count == 2
    }
    
    var cardsToTurn: Array<Int> {
        return cards.indices.filter( { cards[$0].isFaceUp } )
    }

    mutating func rotateCards() {
//        assert(shouldTurnCards)
        for index in cardsToTurn {
            cards[index].isFaceUp = false
        }
    }
    
    mutating func chooseCard(at index: Int) {
        assert(cards.indices.contains(index), "Concentration.chooseCard(at: \(index)): chosen index not in the cards")
        flipCount += 1
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                if cards[matchIndex] == cards[index] {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                    scoreCount += Points.matchBonus
                } else {
                    if seenCards.contains(index) {
                        scoreCount = max(0, scoreCount - Points.missMatchPenalty)
                    }
                    if seenCards.contains(matchIndex) {
                        scoreCount = max(0, scoreCount - Points.missMatchPenalty)
                    }
                    scoreCount = max(0, scoreCount - timePenalty)
                }
                    seenCards.insert(index)
                    seenCards.insert(matchIndex)
                    cards[index].isFaceUp = true
                    lastClick = Date()
            } else {
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    mutating func restartGame() {
        flipCount = 0
        seenCards = []
        scoreCount = 0
        for index in cards.indices {
            cards[index].isMatched = false
            cards[index].isFaceUp = false
        }
        for _ in cards.indices {
            cards.sort(by: {(_,_) in arc4random() < arc4random()})
        }
    }
    
}

extension Date {
    var sinceNow: Int {
        return -Int(self.timeIntervalSinceNow)
    }
}

extension Collection {
    var oneAndOnly: Element? {
        return count == 1 ? first : nil
    }
}
