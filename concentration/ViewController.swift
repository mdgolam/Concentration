//
//  ViewController.swift
//  concentration
//
//  Created by Vlad Md Golam on 22/02/2018.
//  Copyright © 2018 Vlad Md Golam. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    var numberOfPairsOfCards: Int {
            return (cardButtons.count + 1) / 2
    }
    
    @IBOutlet private var cardButtons: [UIButton]!
    @IBOutlet private weak var flipCountLabel: UILabel!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var themeLabel: UILabel!
    @IBOutlet private weak var newGameButton: UIButton!
    @IBOutlet weak var finalMessage: UILabel!
    @IBOutlet weak var finalScore: UILabel!
    
    @IBOutlet weak var infoBar: UIStackView!
    @IBOutlet weak var endGameLabels: UIStackView!
    
    @IBAction func touchCard(_ sender: UIButton) {
        if let cardNumber = cardButtons.index(of: sender), !game.cards[cardNumber].isMatched {
            game.chooseCard(at: cardNumber)
            updateViewFromModel()
        } else {
                print("chosen card was not in cardButtons")
        }
    }
    
    var inProcess: Set<Int> = []
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControlState.normal)
                button.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                    self.turnCardDown(on: button, and: card)
            }
        }

        if game.shouldTurnCards {
            for index in game.cardsToTurn where !inProcess.contains(index) {
                inProcess.insert(index)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // unless they are rotated
                let button = self.cardButtons[index]
                let card = self.game.cards[index]
                    if !self.game.cards[index].isFaceUp {
                        self.turnCardDown(on: button, and: card)
                        self.inProcess.remove(index)
                    }
                }
            }
            game.rotateCards()
        }
        
        endGameLabels.isHidden = !game.isWon
        infoBar.isHidden = game.isWon
        
        if !game.isWon {
            scoreLabel.text = "Score: \(game.scoreCount)"
            updateFlipCountLabel()
        } else {
            finalScore.text = "Your score is \(game.scoreCount)"
        }
    }
    
    private func turnCardDown(on button: UIButton, and card: Card) {
        button.backgroundColor = card.isMatched ? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0) : self.cardBackColor
        button.setTitle("", for: UIControlState.normal)
    }
    
    private func updateFlipCountLabel() {
        let attributes: [NSAttributedStringKey:Any] = [:]
        let attributedString = NSAttributedString(string: "Flips: \(game.flipCount)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    
    private var emoji = [Card:String]()
    private var emojiChoices = ""
    
    private typealias Theme = (emojiChoices: String, backgroundColor: UIColor, cardBackColor: UIColor)
    
    private var emojiThemes: [String:Theme] = [
        "Everything": ("🦇😇😈🎃👻🧚‍♂️👓🎓👁👀🧤🌍🌜🌹",#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)),
        "Nature": ("🌕🌗🌚🌍⭐️☀️🌞🌑💫❄️🌈🌪🔥☄️",#colorLiteral(red: 0.3764705882, green: 0.6980392157, blue: 0.2117647059, alpha: 1),#colorLiteral(red: 0.9843137255, green: 0.8392156863, blue: 0.07843137255, alpha: 1)),
        "LittleOnes": ("🐬🐳🐍🐠🐊🧚‍♂️🦋🐚🐗🐨🐼🐶🐥🦀",#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1),#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)),
        "Food": ("🍏🍌🍉🍇🌶🥑🥦🥔🍅🥥🍎🍓🍈🍑",#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)),
        "Activities": ("🏊🏼‍♀️🧘🏽‍♂️⛹🏽‍♂️🏄🏽‍♂️🤸🏽‍♀️🏋🏽‍♀️🏂⛷🚴🏽‍♀️🧗🏽‍♂️🤺🤾🏿‍♀️🤼‍♂️🚣🏽‍♂️",#colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)),
        "Commute": ("🏍🚟🚃🚅🏎🚲🛴🚃⛵️🗿🚢🛸✈️🚀",#colorLiteral(red: 0.4745098039, green: 0.6784313725, blue: 0.862745098, alpha: 1) ,#colorLiteral(red: 1, green: 0.7529411765, blue: 0.6235294118, alpha: 1))
    ]
    // TODO: 🧞‍♀️🧞‍♂️🧜🏻‍♀️🧜🏻‍♂️🧚🏻‍♀️🧚🏻‍♂️
    // 🧙🏻‍♀️🧙🏻‍♂️🧝🏻‍♀️🧝🏻‍♂️🧛🏻‍♀️🧛🏻‍♂️🧟‍♀️🧟‍♂️
    // 🐲🐉
    
    private var keys: [String] {return Array(emojiThemes.keys)}
    
    private var backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    private var cardBackColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    
    private var themeChoice = 0 {
        didSet {
            (emojiChoices, backgroundColor, cardBackColor) = emojiThemes[keys [themeChoice]] ?? ("",#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
            emoji = [:]
            themeLabel.text = keys[themeChoice]
            updateAppearance()
        }
    }
    
    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiChoices.count > 0 {
            let randomStringIndex = emojiChoices.index(emojiChoices.startIndex, offsetBy: emojiChoices.count.arc4random)
            emoji[card] = String(emojiChoices.remove(at: randomStringIndex))
        }
        return emoji[card] ?? "?"
    }
    
    @IBAction func startNewGameButton(_ sender: UIButton) {
        themeChoice = Int(arc4random_uniform(UInt32(keys.count)))
        game.restartGame()
        updateViewFromModel()
    }
    
    func updateAppearance() {
        view.backgroundColor = backgroundColor
        flipCountLabel.textColor = cardBackColor
        scoreLabel.textColor = cardBackColor
        themeLabel.textColor = cardBackColor
        newGameButton.setTitleColor(cardBackColor, for: .normal)
        finalMessage.textColor = cardBackColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeChoice = Int(arc4random_uniform(UInt32(keys.count)))
        updateViewFromModel()
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}
