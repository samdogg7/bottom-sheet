//
//  BottomSheetConfiguration.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import SwiftUI

@Observable
class BottomSheetConfiguration {
    var sheetColor: Color?
    var dragIndicator: DragIndicator
    var selectedDetent: Detent
    var detents: [Detent]
    var cornerRadius: CGFloat
    /// Edges that ignore the safe area
    var ignoredEdges: Edge.Set

    /// Indicates if the bottom sheet's initial `selectedDetent` state has been set
    var setInitialDetent = false

    init(
        sheetColor: Color? = nil,
        dragIndicator: DragIndicator = .init(),
        detents: [Detent] = [.large],
        cornerRadius: CGFloat = 20,
        ignoredEdges: Edge.Set = []
    ) {
        self.sheetColor = sheetColor
        self.dragIndicator = dragIndicator
        self.cornerRadius = cornerRadius
        self.ignoredEdges = ignoredEdges
        
        var detents = detents

        // Ensure there is always a detent present in `detents`
        if detents.isEmpty {
            assertionFailure("`detents` should always be populated")
            detents.append(.large)
        }
        self.detents = detents

        guard let smallestDetent = detents.smallest else {
            preconditionFailure("`smallestDetent` should never be nil, based on the prior logic")
        }

        self.selectedDetent = smallestDetent
    }
}

extension BottomSheetConfiguration {
    struct DragIndicator {
        var isPresented: Bool = false
        var color: Color = .gray
    }
}