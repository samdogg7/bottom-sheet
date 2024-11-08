//
//  BottomSheetView.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @State private var contentHeight: CGFloat = 0.0
    @State private var sheetHeight: CGFloat = 0.0
    @State private var enableDragGesture = true

    @Binding private var configuration: BottomSheetViewConfiguration
    @Binding private var selectedDetent: Detent

    var detents: [Detent] {
        configuration.detents
    }

    /// Content to be displayed behind the sheet
    private let content: Content

    init(
        configuration: Binding<BottomSheetViewConfiguration>,
        selectedDetent: Binding<Detent>,
        content: Content
    ) {
        self._configuration = configuration
        self._selectedDetent = selectedDetent
        self.content = content
    }
    
    private var dragIndicator: some View {
        VStack {
            Capsule()
                .frame(width: 50, height: 5)
                .foregroundStyle(configuration.dragIndicator.color)
                .padding(.top, 5)
            
            Spacer()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                
                content
                    .overlay(content: {
                        if configuration.dragIndicator.isPresented {
                            dragIndicator
                        }
                    })
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: sheetHeight)
                    .background(configuration.sheetColor)
                    .clipShape(
                        .rect(
                            topLeadingRadius: configuration.cornerRadius,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0,
                            topTrailingRadius: configuration.cornerRadius
                        )
                    )
                    .shadow(radius: 10)
                    .animation(.spring, value: sheetHeight)
                    // Ensures `DragGesture` works everywhere on sheet
                    .contentShape(.rect)
                    .scrollDisabled(enableDragGesture)
                    .onScrollGeometryChange(for: Double.self) { geometry in
                        geometry.contentOffset.y
                    } action: { _, offset in
                        enableDragGesture = offset <= 0
                    }
                    .simultaneousGesture(
                        DragGesture()
                        .onChanged({ value in
                            dragGestureOnChanged(value)
                        })
                        .onEnded({ value in
                            dragGestureOnEnded(value)
                        })
                    )
            }
            .onChange(of: geometry.size.height, { _, newValue in
                contentHeight = newValue
            })
            .onAppear {
                contentHeight = geometry.size.height
                sheetHeight = selectedDetent.fraction * contentHeight
            }
        }.ignoresSafeArea(edges: configuration.ignoredEdges)
    }
}

extension BottomSheetView {

    var maxFraction: CGFloat {
        detents.map(\.fraction).max() ?? 0.0
    }

    var minFraction: CGFloat {
        detents.map(\.fraction).min() ?? 1.0
    }

    func dragGestureOnChanged(_ gesture: DragGesture.Value) {
        guard enableDragGesture else { return }

        let desiredHeight = sheetHeight - gesture.translation.height

        let minHeight = minFraction * contentHeight
        let maxHeight = maxFraction * contentHeight

        // Clamp desired height within bounds
        let clampedDesiredHeight = max(minHeight, min(desiredHeight, maxHeight))

        updateSheetHeight(to: clampedDesiredHeight)
    }
    
    func dragGestureOnEnded(_ gesture: DragGesture.Value) {
        // Calculate the current fraction of the screen height
        let currentFraction = sheetHeight / contentHeight

        // Find the closest detent based on the current fraction
        self.selectedDetent = detents.min(by: {
            abs($0.fraction - currentFraction) < abs($1.fraction - currentFraction)
        }) ?? .small

        // Calculate the desired height for the closest detent
        let desiredHeight = contentHeight * selectedDetent.fraction

        updateSheetHeight(to: desiredHeight)
    }

    private func updateSheetHeight(to desiredHeight: CGFloat) {
        let maxHeight = maxFraction * contentHeight
        let previousSheetHeight = sheetHeight
        
        self.sheetHeight = desiredHeight

        if previousSheetHeight != sheetHeight && sheetHeight == maxHeight {
            enableDragGesture = false
        }
    }
}
