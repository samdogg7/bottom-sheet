//
//  BottomSheet.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import SwiftUI

public struct SplitView<Content: View, SheetContent: View>: View {
    @State var configuration = BottomSheetConfiguration()

    private let isPresented: Bool
    private let content: Content
    private let sheetContent: SheetContent

    public init(
        isPresented: Bool = true,
        @ViewBuilder content: () -> Content,
        @ViewBuilder sheetContent: () -> SheetContent
    ) {
        self.isPresented = isPresented
        self.content = content()
        self.sheetContent = sheetContent()
    }
    
    public var body: some View {
        ZStack {
            content
            
            if isPresented {
                BottomSheet(
                    configuration: $configuration,
                    content: sheetContent
                )
            }
        }
    }
}

public extension View {

    func bottomSheet<SheetContent: View>(
        isPresented: Bool = true,
        @ViewBuilder sheetContent: () -> SheetContent
    ) -> SplitView<Self, SheetContent> {
        SplitView(
            isPresented: isPresented,
            content: { self },
            sheetContent: sheetContent
        )
    }

}

private struct ExampleView: View {
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]

    @ViewBuilder
    var rainbowList: some View {
        List {
            ForEach((0..<colors.count * 4), id: \.self) { index in
                let color = colors[index % colors.count]
                Text(color.description)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .listRowBackground(color)
            }
        }
        .listStyle(.plain)
    }

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map") {
                SplitView {
                    Text("Map")
                } sheetContent: {
                    rainbowList
                }
                .dragIndicator(true)
                .detents([.small, .medium, .large])
            }

            Tab("Settings", systemImage: "gear") {
                Text("Settings")
            }
        }
    }
}

#Preview {
    ExampleView()
}

