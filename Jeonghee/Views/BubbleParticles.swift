//
//  BubbleParticles.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct BubbleParticles: View {
    let count = 8

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 8, height: 8)
                    .offset(particleOffset(i))
                    .opacity(0.7)
            }
        }
        .scaleEffect(1.4)
        .animation(.easeOut(duration: 0.35), value: UUID())
    }

    private func particleOffset(_ index: Int) -> CGSize {
        let angle = Double(index) / Double(count) * 2 * .pi
        return CGSize(
            width: cos(angle) * 40,
            height: sin(angle) * 40
        )
    }
}


