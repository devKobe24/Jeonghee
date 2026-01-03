//
//  MainMenuView.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct MainMenuView: View {
    @State private var showGame = false
    @State private var showAlbum = false
    @State private var animate = false
    @State private var currentStage = 1  // 현재 게임 단계 (1-5)
    @State private var usedImageIndices: Set<Int> = []  // 사용한 이미지 인덱스들
    
    var body: some View {
        ZStack {
            // 배경 (추후 이미지 추가 예정)
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // 게임 타이틀 (선택사항)
                Text("학습 게임")
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
                    .padding(.bottom, 50)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
                
                Spacer()
                
                // 버튼들
                VStack(spacing: 20) {
                    // 게임 시작 버튼 (초록색)
                    Button(action: {
                        currentStage = 1
                        usedImageIndices = []
                        showGame = true
                    }) {
                        Text("게임 시작")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 60)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.green,
                                        Color(red: 0.0, green: 0.7, blue: 0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animate)
                    
                    // 앨범 버튼 (회색)
                    Button(action: {
                        showAlbum = true
                    }) {
                        Text("앨범")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 60)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.gray,
                                        Color(red: 0.4, green: 0.4, blue: 0.4)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15), value: animate)
                    
                    // 게임 종료 버튼 (빨간색)
                    Button(action: {
                        exit(0)
                    }) {
                        Text("게임 종료")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 60)
                            .padding(.vertical, 20)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.red,
                                        Color(red: 0.8, green: 0.0, blue: 0.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: animate)
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            animate = true
        }
        .fullScreenCover(isPresented: $showGame) {
            let savedImages = ImageStorageService.shared.loadImages()
            let maxStage = max(1, savedImages.count)  // 저장된 이미지 개수만큼 단계 설정 (최소 1)
            
            if currentStage <= maxStage {
                NumberPopGameView(
                    stage: currentStage,
                    maxStage: maxStage,
                    rewardImageName: nil,
                    rewardImages: [],
                    usedImageIndices: usedImageIndices,
                    onNextStage: { imageIndex in
                        // 다음 단계로 이동
                        if let imageIndex = imageIndex {
                            usedImageIndices.insert(imageIndex)
                        }
                        if currentStage < maxStage {
                            currentStage += 1
                        } else {
                            // 마지막 단계 완료 후 게임 종료
                            showGame = false
                            currentStage = 1
                            usedImageIndices = []
                        }
                    }
                )
                .id(currentStage)  // 단계가 변경되면 뷰를 다시 생성
            }
        }
        .sheet(isPresented: $showAlbum) {
            AlbumView()
        }
    }
}

#Preview {
    MainMenuView()
}

