//
//  CompletionScreenView.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct CompletionScreenView: View {
    let onRestart: () -> Void
    let onQuit: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // 배경
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 축하 메시지
                Text("🎉 완료! 🎉")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.4, blue: 0.7),
                                Color(red: 1.0, green: 0.2, blue: 0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .opacity(animate ? 1 : 0)
                
                // 별 표시
                HStack(spacing: 20) {
                    ForEach(0..<3) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                            .scaleEffect(animate ? 1.0 : 0.3)
                            .opacity(animate ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.5)
                                .delay(Double(index) * 0.2),
                                value: animate
                            )
                    }
                }
                
                // 축하 텍스트
                Text("모든 숫자를\n순서대로 눌렀어요!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                
                // 버튼들
                VStack(spacing: 15) {
                    // 다시 하기 버튼
                    Button(action: onRestart) {
                        Text("다시 하기")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.7),
                                        Color(red: 1.0, green: 0.2, blue: 0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    
                    // 그만 하기 버튼
                    Button(action: onQuit) {
                        Text("그만 하기")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
                .scaleEffect(animate ? 1.0 : 0.8)
            }
            .padding()
        }
        .onAppear {
            withAnimation {
                animate = true
            }
        }
    }
}

