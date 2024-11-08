//
//  BottomSheetView.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    @State private var sheetHeight: CGFloat = 0.0
    @State private var contentOffset: CGFloat = 0.0

    @Binding private var configuration: BottomSheetViewConfiguration
    @Binding private var selectedDetent: Detent

    var detents: [Detent] {
        configuration.detents
    }

    /// Content to be displayed behind the sheet
    private let content: Content

    /// Adjust this value to change the smoothing factor for on change drag gesture
    private let smoothingFactor: CGFloat = 0.2

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
                    .scrollDisabled(selectedDetent != detents.largest && contentOffset <= 0)
                    .onScrollGeometryChange(for: Double.self) { geometry in
                        geometry.contentOffset.y
                    } action: { oldValue, newValue in
                        contentOffset = newValue

                        let scrolledToTop = newValue <= 0 && oldValue > 0
                        if scrolledToTop {
                            selectedDetent = detents.largest ?? selectedDetent
                        }

                        let scrollingDown = newValue <= 0.0 && selectedDetent == detents.largest
                        if scrollingDown {
                            // Screen height can be no larger than `screenHeight`
                            // and no smaller than the minimum detent height
                            sheetHeight = min(
                                screenHeight,
                                max(
                                    minHeight(for: screenHeight),
                                    sheetHeight + newValue
                                )
                            )
                            let closestDetent = detents
                                .filter { $0 != detents.largest }
                                .min(by: { abs($0.fraction * screenHeight - sheetHeight) < abs($1.fraction * screenHeight - sheetHeight) })
                            
                            if let closestDetent = closestDetent {
                                selectedDetent = closestDetent
                            }
                        }
                    }
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
        // Ensure we aren't scrolling underlying `ScrollView` / `List`
        guard contentOffset <= 0 else { return }

        let desiredHeight = sheetHeight - gesture.translation.height

        guard desiredHeight != sheetHeight else { return }

        let minHeight = minHeight(for: screenHeight)
        let maxHeight = maxFraction * screenHeight

        // Clamp desired height within bounds
        let clampedDesiredHeight = max(minHeight, min(desiredHeight, maxHeight))
        
        // Smooth the transition between the current height and the target
        sheetHeight = (sheetHeight * (1 - smoothingFactor)) + (clampedDesiredHeight * smoothingFactor)
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
        self.sheetHeight = desiredHeight
    }

    func minHeight(for screenHeight: CGFloat) -> CGFloat {
        minFraction * screenHeight
    }
}
