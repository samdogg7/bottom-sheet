//
//  BottomSheetView.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
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
            let screenHeight = geometry.size.height

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
                    } action: { _, newValue in
                        enableDragGesture = newValue <= 0
                    }
                    .simultaneousGesture(
                        DragGesture()
                        .onChanged({ gesture in
                            dragGestureOnChanged(gesture, screenHeight: screenHeight)
                        })
                        .onEnded({ gesture in
                            dragGestureOnEnded(gesture, screenHeight: screenHeight)
                        })
                    )
            }
            .onAppear {
                sheetHeight = selectedDetent.fraction * screenHeight
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

    func dragGestureOnChanged(_ gesture: DragGesture.Value, screenHeight: CGFloat) {
        guard enableDragGesture else { return }

        let desiredHeight = sheetHeight - gesture.translation.height

        guard desiredHeight != sheetHeight else { return }

        let minHeight = minHeight(for: screenHeight)
        let maxHeight = maxFraction * screenHeight

        // Clamp desired height within bounds
        let clampedDesiredHeight = max(minHeight, min(desiredHeight, maxHeight))
        
        updateSheetHeight(to: clampedDesiredHeight, screenHeight: screenHeight)
    }
    
    func dragGestureOnEnded(_ gesture: DragGesture.Value, screenHeight: CGFloat) {
        // Calculate the current fraction of the screen height
        let currentFraction = sheetHeight / screenHeight

        // Find the closest detent based on the current fraction
        let closestDetent = detents.min(by: {
            abs($0.fraction - currentFraction) < abs($1.fraction - currentFraction) 
        }) ?? .small

        // Calculate the desired height for the closest detent
        let desiredHeight = screenHeight * closestDetent.fraction

        // Update the selected detent and animate to the desired height
        self.selectedDetent = closestDetent

        updateSheetHeight(to: desiredHeight, screenHeight: screenHeight)
    }

    func minHeight(for screenHeight: CGFloat) -> CGFloat {
        minFraction * screenHeight
    }

    private func updateSheetHeight(to desiredHeight: CGFloat, screenHeight: CGFloat) {
        let maxHeight = maxFraction * screenHeight
        let previousSheetHeight = sheetHeight
        
        self.sheetHeight = desiredHeight

        if previousSheetHeight != sheetHeight && sheetHeight == maxHeight {
            enableDragGesture = false
        }
    }
}
