//
//  Dice.swift
//  DiceyRoll
//
//  Created by Jemerson Canaya on 3/12/25.
//
import SwiftUI
import SwiftData

enum DiceSide: Int, Codable {
    case fourSided = 4,
         sixSided = 6,
         eightSided = 8,
         tenSided = 10,
         twelveSided = 12,
         twentySided = 20,
         oneHundredSided = 100
}

@Model
class Dice {

    var id: Int
    var diceSide: DiceSide {
        get { DiceSide(rawValue: diceSideValue) ?? .fourSided }
        set { diceSideValue = newValue.rawValue }
    }
    var diceSideValue: Int
    var currentValue: Int {
        get { tempValue }
        set {
            tempValue = newValue
            totalValue += newValue
        }
    }
    var totalValue: Int
    var isSelected: Bool = false
    
    init(id: Int, diceSide: DiceSide = .fourSided, currentValue: Int, totalValue: Int) {
        self.id = id
        self.diceSideValue = diceSide.rawValue
        self.tempValue = currentValue
        self.totalValue = totalValue
    }
    
    var tempValue: Int
    
    var diceSideText: String {
        switch diceSide {
        case .fourSided:
            "Four-sided dice"
        case .sixSided:
            "Six-sided dice"
        case .eightSided:
            "Eight-sided dice"
        case .tenSided:
            "Ten-sided dice"
        case .twelveSided:
            "Twelve-sided dice"
        case .twentySided:
            "Twenty-sided dice"
        case .oneHundredSided:
            "One hundred-sided dice"
        }
    }
    
    static var example: Dice {
        Dice(id: Int.random(in: 0...50), diceSide: .fourSided, currentValue: Int.random(in: 1...6), totalValue: Int.random(in: 0...100))
    }
    
    static var exampleArray: [Dice] {
        [
            Dice.example,
            Dice.example
        ]
    }
    
}
