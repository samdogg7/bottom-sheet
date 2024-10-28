//
//  Detent.swift
//  BottomSheet
//
//  Created by Wojciech Konury on 23/10/2024.
//

import Foundation

public enum Detent: Equatable {
    case large
    case medium
    case small
    case hidden
    case fraction(CGFloat)
    
    var fraction: CGFloat {
        switch self {
        case .large:
            return 1
        case .medium:
            return 0.50
        case .small:
            return 0.20
        case .hidden:
            return 0.0
        case .fraction(let value):
            return value
        }
    }
    
    static func forValue(_ value: CGFloat, from detents: [Detent]) -> Detent {
        return detents.min(by: { abs($0.fraction - value) < abs($1.fraction - value) }) ?? .small
    }
}

extension Array where Element == Detent {

    var smallest: Detent? {
        self.min(by: { $0.fraction < $1.fraction })
    }

    var smallestExcludingHidden: Detent? {
        var detents = self
        detents.removeAll { $0 == .hidden }
        return detents.smallest
    }

}
