//
//  PoppableBubbleNumber.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct PoppableBubbleNumber: View {

    let value: String
    let onTap: () -> Void
    let shakeTrigger: Int
    let shouldPop: Bool
    let isTarget: Bool

    @State private var isPopped = false
    @State private var isVisible = true
    @State private var numberScale: CGFloat = 1.0   // 👈 숫자 전용 스케일

    var body: some View {
        if isVisible {
            ZStack {
                if isPopped {
                    BubbleParticles()
                }

                // 3D 풍선 글씨 스타일 - 그림자 레이어
                Text(value)
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: 3, y: 3)
                    .scaleEffect(numberScale)
                
                // 3D 풍선 글씨 스타일 - 메인 레이어
                Text(value)
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.7),  // 핫핑크
                                Color(red: 1.0, green: 0.2, blue: 0.6)    // 진한 핑크
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(numberScale)
                    .modifier(
                        ShakeEffect(
                            amount: 14,
                            shakesPerUnit: 3,
                            animatableData: CGFloat(shakeTrigger)
                        )
                    )
                    .animation(.default, value: shakeTrigger)
            }
            .scaleEffect(isPopped ? 1.8 : 1.0)
            .opacity(isPopped ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: isPopped)

            // 🎯 숫자 커짐 제어
            .onAppear {
                if isTarget {
                    growNumber()
                }
            }
            .onChange(of: isTarget) { newValue in
                if newValue {
                    growNumber()
                } else {
                    numberScale = 1.0
                }
            }

            .onTapGesture {
                onTap()
                if shouldPop {
                    pop()
                }
            }
        }
    }

    // MARK: - 숫자 커짐 애니메이션 (1회성)
    private func growNumber() {
        numberScale = 1.0
        withAnimation(.easeOut(duration: 0.6)) {
            numberScale = 2.55  // 👈 점점 커짐
        }
    }

    private func pop() {
        isPopped = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isVisible = false
        }
    }
}
