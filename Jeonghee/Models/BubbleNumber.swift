//
//  BubbleNumber.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct BubbleNumber: Identifiable {
    let id = UUID()
    let value: Int
    let position: CGPoint
    let rotation: Double
    let scale: Double
}
