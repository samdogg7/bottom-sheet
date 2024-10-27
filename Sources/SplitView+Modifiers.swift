//
//  BottomSheet+Modifiers.swift
//  BottomSheet
//
//  Created by Sam Doggett on 10/27/24.
//

import SwiftUI

public extension SplitView {

    func sheetColor(_ color: Color) -> SplitView {
        configuration.sheetColor = color
        return self
    }

    func dragIndicator(_ isVisible: Bool) -> SplitView {
        configuration.dragIndicator = .init(isPresented: isVisible, color: configuration.dragIndicator.color)
        return self
    }

    func dragIndicatorColor(_ color: Color = .gray) -> SplitView {
        configuration.dragIndicator = .init(isPresented: configuration.dragIndicator.isPresented, color: color)
        return self
    }

    func detents(_ detents: [Detent], initialDetent: Detent? = nil) -> SplitView {
        var detents = detents
        if detents.isEmpty {
            assertionFailure("`detents` should never be empty")
            detents.append(.large)
        }
        if let initialDetent = initialDetent ?? detents.smallest, !configuration.setInitialDetent {
            configuration.selectedDetent = initialDetent
        }
        configuration.detents = detents
        return self
    }

}
