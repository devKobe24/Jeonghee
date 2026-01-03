//
//  RewardScreenView.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct RewardScreenView: View {
    var imageName: String? = nil  // 기존 방식 (Asset 이미지)
    var rewardImage: UIImage? = nil  // 새로운 방식 (앨범에서 선택한 이미지)
    var currentStage: Int = 1  // 현재 단계
    var maxStage: Int = 1  // 최대 단계 수
    let onNext: () -> Void
    let onComplete: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // 배경
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // 보상 이미지 (최고 해상도 유지)
                GeometryReader { imageGeo in
                    Group {
                        if let rewardImage = rewardImage {
                            // 앨범에서 선택한 이미지
                            Image(uiImage: rewardImage)
                                .resizable()
                                .interpolation(.high)  // 고품질 보간
                                .antialiased(true)  // 안티앨리어싱 활성화
                                .scaledToFit()
                                .frame(
                                    width: min(imageGeo.size.width, UIScreen.main.bounds.width),
                                    height: min(imageGeo.size.height, UIScreen.main.bounds.height)
                                )
                                .clipped()
                        } else if let imageName = imageName {
                            // Asset 이미지
                            Image(imageName)
                                .resizable()
                                .interpolation(.high)  // 고품질 보간
                                .antialiased(true)  // 안티앨리어싱 활성화
                                .scaledToFit()
                                .frame(
                                    width: min(imageGeo.size.width, UIScreen.main.bounds.width),
                                    height: min(imageGeo.size.height, UIScreen.main.bounds.height)
                                )
                                .clipped()
                        }
                    }
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
                }
                .padding()
                
                Spacer()
                
                // 버튼들
                VStack(spacing: 15) {
                    // 다음 단계 버튼 (마지막 단계가 아닐 때만 표시)
                    if currentStage < maxStage {
                        Button(action: onNext) {
                            Text("다음 단계")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 50)
                                .padding(.vertical, 18)
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
                                .cornerRadius(30)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                    }
                    
                    // 완료 버튼
                    Button(action: onComplete) {
                        Text("완료")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 50)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.gray.opacity(0.2))
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.bottom, 50)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 20)
                .scaleEffect(animate ? 1.0 : 0.8)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: animate)
            }
        }
        .onAppear {
            animate = true
        }
    }
}

