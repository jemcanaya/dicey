//
//  VerticalAlignment.swift
//  DiceyRoll
//
//  Created by Jemerson Canaya on 3/12/25.
//
import SwiftUI

extension VerticalAlignment {
    struct MidDiceAndValue: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.top]
        }
    }
    
    static let midDiceAndValue = VerticalAlignment(MidDiceAndValue.self)
}
