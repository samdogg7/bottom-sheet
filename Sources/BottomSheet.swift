//
//  BottomSheetView.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    @State private var viewHeight: CGFloat = 0.0
    @State private var sheetHeight: CGFloat = 0.0
    @State private var isNegativeScrollOffset = false

    @Binding private var configuration: BottomSheetConfiguration

    private let content: Content

    /// Adjust this value to change the smoothing factor for on change drag gesture
    private let smoothingFactor: CGFloat = 0.2
    
    init(configuration: Binding<BottomSheetConfiguration>, content: Content) {
        self._configuration = configuration
        self.content = content
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            content
                .scrollDisabled(isMaxDetentReached)
                .onScrollGeometryChange(for: Double.self) { geometry in
                    return geometry.contentOffset.y
                } action: { oldValue, newValue in
                    if newValue < 0.0 {
                        sheetHeight = max(
                            minHeight,
                            sheetHeight + newValue
                        )
                    }
                    
                    isNegativeScrollOffset = newValue < 0.0
                }
                .overlay(content: {
                    if configuration.dragIndicator.isPresented {
                        VStack {
                            Capsule()
                                .frame(width: 50, height: 5)
                                .foregroundStyle(configuration.dragIndicator.color)
                                .padding(.top, 5)
                            
                            Spacer()
                        }
                    }
                })
                .frame(maxWidth: .infinity)
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
                .animation(.easeInOut, value: sheetHeight)
                .gesture(
                    DragGesture()
                        .onChanged({ gesture in
                            dragGestureOnChanged(gesture)
                        })
                        .onEnded({ gesture in
                            dragGestureOnEnded(gesture)
                        })
                )
        }
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        viewHeight = geometry.size.height
                    }
                    .onChange(of: geometry.size.height) { _, newHeight in
                        viewHeight = newHeight
                    }
            }
        )
        .onAppear {
            sheetHeight = configuration.selectedDetent.fraction * viewHeight
        }
    }
}

extension BottomSheet {

    var maxFraction: CGFloat {
        configuration.detents.map(\.fraction).max() ?? 0.0
    }

    var minFraction: CGFloat {
        configuration.detents.map(\.fraction).min() ?? 1.0
    }

    var isMaxDetentReached: Bool {
        if isNegativeScrollOffset == true {
            return true
        }

        return (viewHeight * maxFraction) > sheetHeight
    }

    var maxHeight: CGFloat {
        maxFraction * viewHeight
    }

    var minHeight: CGFloat {
        minFraction * viewHeight
    }
    
    func dragGestureOnChanged(_ gesture: DragGesture.Value) {
        let desiredHeight = sheetHeight - gesture.translation.height

        guard desiredHeight != sheetHeight else { return }

        // Clamp desired height within bounds
        let clampedDesiredHeight = max(minHeight, min(desiredHeight, maxHeight))
        
        // Smooth the transition between the current height and the target
        sheetHeight = (sheetHeight * (1 - smoothingFactor)) + (clampedDesiredHeight * smoothingFactor)
    }
    
    func dragGestureOnEnded(_ gesture: DragGesture.Value) {
        let selectedDetent = Detent.forValue(
            sheetHeight / viewHeight,
            from: configuration.detents
        )

        let desiredHeight = viewHeight * selectedDetent.fraction

        if desiredHeight < minHeight {
            return
        }

        configuration.selectedDetent = selectedDetent
        sheetHeight = desiredHeight
    }

}
