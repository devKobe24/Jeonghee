//
//  StarParticles.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct StarParticles: View {
    let count = 12
    
    @State private var animate = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 20))
                    .offset(starOffset(i))
                    .opacity(opacity)
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animate = true
                scale = 2.0
                opacity = 0
            }
        }
    }
    
    private func starOffset(_ index: Int) -> CGSize {
        let angle = CGFloat(index) / CGFloat(count) * 2 * .pi
        let distance: CGFloat = animate ? 80 : 0
        return CGSize(
            width: cos(angle) * distance,
            height: sin(angle) * distance
        )
    }
}

