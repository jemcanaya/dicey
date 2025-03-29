//
//  View-Extension.swift
//  DiceyRoll
//
//  Created by Jemerson Canaya on 3/13/25.
//
import SwiftUI

struct HiddenModifier: ViewModifier {
    let isHidden: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isHidden ? 0 : 1)
            .allowsHitTesting(!isHidden)
    }
}

extension View {
    func hidden(_ isHidden: Bool) -> some View {
        self.modifier(HiddenModifier(isHidden: isHidden))
    }
}
