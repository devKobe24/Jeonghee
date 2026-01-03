//
//  NumberPopGameView.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI

struct NumberPopGameView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Parameters
    var stage: Int = 1  // 현재 게임 단계
    var maxStage: Int = 1  // 최대 단계 수 (앨범에서 선택한 사진 개수)
    var rewardImageName: String? = nil  // 보상 이미지 이름 (deprecated - rewardImages 사용)
    var rewardImages: [UIImage] = []  // 단계별 보상 이미지들 (앨범에서 선택한 사진들)
    var selectedImageIndex: Int? = nil  // 선택된 이미지 인덱스
    var usedImageIndices: Set<Int> = []  // 이미 사용한 이미지 인덱스들
    var onNextStage: ((Int?) -> Void)? = nil  // 다음 단계로 이동하는 콜백 (사용한 이미지 인덱스 전달)
    
    // MARK: - Constants
    private let totalNumbers = 10
    
    // MARK: - State
    @State private var currentTarget: Int = 1
    @State private var stageImage: UIImage? = nil  // 현재 단계에서 사용할 이미지
    @State private var stageImageIndex: Int? = nil  // 현재 단계에서 사용한 이미지 인덱스
    @State private var poppedNumbers: Set<Int> = []
    @State private var bubbles: [BubbleNumber] = []
    @State private var shakeCounts: [Int: Int] = [:]
    @State private var showCompletionScreen = false
    @State private var showRewardScreen = false
    @State private var visibleBubbles: Set<UUID> = []
    @State private var showStarParticles = false
    @State private var starParticlePosition: CGPoint = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 배경 이미지 (진행률에 따라 1/10씩 보이기)
                // 저장된 이미지가 있으면 무작위로 선택한 이미지 사용, 없으면 rewardImageName 사용
                if let stageImage = stageImage, !showRewardScreen {
                    GeometryReader { imageGeo in
                        let progress = CGFloat(currentTarget - 1) / CGFloat(totalNumbers)
                        let revealedHeight = imageGeo.size.height * progress
                        
                        ZStack(alignment: .top) {
                            // 전체 이미지
                            Image(uiImage: stageImage)
                                .resizable()
                                .interpolation(.high)
                                .antialiased(true)
                                .scaledToFill()
                                .frame(width: imageGeo.size.width, height: imageGeo.size.height)
                                .clipped()
                            
                            // 위에서부터 아래로 진행률만큼만 보이도록 마스킹
                            // 가려지는 부분 (아래쪽)
                            VStack {
                                Spacer()
                                    .frame(height: revealedHeight)
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: max(0, imageGeo.size.height - revealedHeight))
                            }
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentTarget)
                        }
                    }
                    .ignoresSafeArea()
                } else if let imageName = rewardImageName, !showRewardScreen {
                    GeometryReader { imageGeo in
                        let progress = CGFloat(currentTarget - 1) / CGFloat(totalNumbers)
                        let revealedHeight = imageGeo.size.height * progress
                        
                        ZStack(alignment: .top) {
                            // 전체 이미지
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: imageGeo.size.width, height: imageGeo.size.height)
                                .clipped()
                            
                            // 위에서부터 아래로 진행률만큼만 보이도록 마스킹
                            // 가려지는 부분 (아래쪽)
                            VStack {
                                Spacer()
                                    .frame(height: revealedHeight)
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: max(0, imageGeo.size.height - revealedHeight))
                            }
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentTarget)
                        }
                    }
                    .ignoresSafeArea()
                }
                
                if showRewardScreen {
                    // 보상 이미지 화면
                    if let stageImage = stageImage {
                        // 저장된 이미지 사용
                        RewardScreenView(
                            rewardImage: stageImage,
                            currentStage: stage,
                            maxStage: maxStage,
                            onNext: {
                                // 다음 단계로 이동 또는 완료 화면으로 이동
                                if let onNextStage = onNextStage, stage < maxStage {
                                    onNextStage(stageImageIndex)
                                } else {
                                    showRewardScreen = false
                                    showCompletionScreen = true
                                }
                            },
                            onComplete: {
                                showRewardScreen = false
                                showCompletionScreen = true
                            }
                        )
                    } else if let imageName = rewardImageName {
                        // rewardImageName 사용 (기존 방식)
                        RewardScreenView(
                            imageName: imageName,
                            currentStage: stage,
                            maxStage: maxStage,
                            onNext: {
                                // 다음 단계로 이동 또는 완료 화면으로 이동
                                if let onNextStage = onNextStage, stage < maxStage {
                                    onNextStage(stageImageIndex)
                                } else {
                                    showRewardScreen = false
                                    showCompletionScreen = true
                                }
                            },
                            onComplete: {
                                showRewardScreen = false
                                showCompletionScreen = true
                            }
                        )
                    }
                } else if showCompletionScreen {
                    // 게임 완료 화면
                    CompletionScreenView(
                        onRestart: {
                            restartGame(in: geo.size)
                        },
                        onQuit: {
                            exit(0)
                        }
                    )
                } else {
                    // 진행률 표시
                    VStack {
                        HStack {
                            // 진행률 바
                            GeometryReader { progressGeo in
                                ZStack(alignment: .leading) {
                                    // 배경 바
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 20)
                                    
                                    // 진행률 바
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.4, blue: 0.7),
                                                    Color(red: 1.0, green: 0.2, blue: 0.6)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: progressGeo.size.width * CGFloat(currentTarget - 1) / CGFloat(totalNumbers), height: 20)
                                        .animation(.spring(response: 0.3), value: currentTarget)
                                }
                            }
                            .frame(height: 20)
                            
                            // 진행률 텍스트
                            Text("\(currentTarget - 1)/\(totalNumbers)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.leading, 10)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        Spacer()
                    }
                    
                    // 안내 텍스트
                    if currentTarget <= totalNumbers {
                        VStack {
                            Text("\(currentTarget)을 눌러보세요!")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.top, 80)
                            Spacer()
                        }
                    }

                    // 별 파티클 효과
                    if showStarParticles {
                        StarParticles()
                            .position(starParticlePosition)
                    }

                    // 숫자 풍선
                    ForEach(bubbles) { bubble in
                        if bubble.value >= currentTarget && visibleBubbles.contains(bubble.id) {
                            PoppableBubbleNumber(
                                value: "\(bubble.value)",
                                onTap: {
                                    handleTap(bubble.value, at: bubble.position)
                                },
                                shakeTrigger: shakeCounts[bubble.value, default: 0],
                                shouldPop: bubble.value == currentTarget,
                                isTarget: bubble.value == currentTarget
                            )
                            .position(bubble.position)
                            .opacity(visibleBubbles.contains(bubble.id) ? 1 : 0)
                            .scaleEffect(visibleBubbles.contains(bubble.id) ? bubble.scale : 0.3)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: visibleBubbles.contains(bubble.id))
                        }
                    }
                }
            }
            .onAppear {
                startGame(in: geo.size)
            }
            .onChange(of: stage) { _ in
                // 단계가 변경되면 게임 재시작 (숫자 재배치)
                startGame(in: geo.size)
            }
        }
    }

    private func startGame(in size: CGSize) {
        currentTarget = 1
        bubbles = []
        visibleBubbles = []
        showCompletionScreen = false
        showRewardScreen = false
        showStarParticles = false
        poppedNumbers = []
        shakeCounts = [:]
        
        // 저장된 이미지 선택 로직
        // stageImageIndex가 이미 설정되어 있으면 (다시 하기 시) 같은 이미지 사용
        if let existingIndex = stageImageIndex {
            let savedImages = ImageStorageService.shared.loadImages()
            if existingIndex < savedImages.count {
                stageImage = savedImages[existingIndex]
                // stageImageIndex는 이미 설정되어 있으므로 유지
            }
        } else {
            // 각 단계마다 다른 이미지 선택 (이미 사용한 이미지 제외)
            let savedImages = ImageStorageService.shared.loadImages()
            var availableIndices = Array(0..<savedImages.count)
            
            // 이미 사용한 이미지 제외
            for usedIndex in usedImageIndices {
                availableIndices.removeAll { $0 == usedIndex }
            }
            
            // 사용 가능한 이미지가 있으면 무작위로 선택
            if !availableIndices.isEmpty {
                let randomIndex = availableIndices.randomElement()!
                stageImage = savedImages[randomIndex]
                stageImageIndex = randomIndex
            } else if !savedImages.isEmpty {
                // 모든 이미지를 사용했으면 첫 번째 이미지 사용
                stageImage = savedImages[0]
                stageImageIndex = 0
            }
        }

        // 숫자 패드처럼 그리드로 배치
        // 10개의 숫자를 배치하기 위해 3행 4열 그리드 사용 (12개 셀 중 10개 사용)
        let gridCols = 4  // 4열
        let gridRows = 3  // 3행
        
        // 사용 가능한 영역 계산
        let topMargin: CGFloat = 140
        let horizontalPadding: CGFloat = 40
        let verticalPadding: CGFloat = 40
        
        let availableWidth = size.width - horizontalPadding * 2
        let availableHeight = size.height - topMargin - verticalPadding * 2
        
        let cellWidth = availableWidth / CGFloat(gridCols)
        let cellHeight = availableHeight / CGFloat(gridRows)
        
        // 숫자 패드 배치: 1-10을 랜덤하게 섞어서 그리드에 배치
        var numbers = Array(1...10)
        numbers.shuffle()  // 숫자들을 랜덤하게 섞기
        
        // 그리드 셀 인덱스 생성 (0부터 11까지, 10개만 사용)
        var cellIndices = Array(0..<(gridCols * gridRows))
        cellIndices.shuffle()  // 셀 위치도 랜덤하게
        
        // 섞인 숫자들을 랜덤한 그리드 셀에 배치
        for (index, num) in numbers.enumerated() {
            guard index < cellIndices.count else { break }
            
            let cellIndex = cellIndices[index]
            let row = cellIndex / gridCols
            let col = cellIndex % gridCols
            
            // 셀 중심 위치 계산 (정확한 그리드 중앙)
            let x = horizontalPadding + cellWidth * (CGFloat(col) + 0.5)
            let y = topMargin + verticalPadding + cellHeight * (CGFloat(row) + 0.5)
            
            let bubble = BubbleNumber(
                value: num,
                position: CGPoint(x: x, y: y),
                rotation: 0,
                scale: 1.0  // 고정 배치이므로 스케일 변동 제거
            )
            
            bubbles.append(bubble)
            
            // 숫자 등장 애니메이션 (순차적으로 나타나기)
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    _ = visibleBubbles.insert(bubble.id)
                }
            }
        }
    }
    
    private func restartGame(in size: CGSize) {
        // "다시 하기"를 누를 때는 같은 이미지를 다시 사용하기 위해
        // stageImageIndex는 이미 설정되어 있으므로 startGame에서 자동으로 재사용됨
        startGame(in: size)
    }

    private func handleTap(_ value: Int, at position: CGPoint) {
        if value == currentTarget {
            SpeechService.shared.speak("\(value)")
            
            // 성공 시 별 파티클 표시
            starParticlePosition = position
            showStarParticles = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showStarParticles = false
            }
            
            poppedNumbers.insert(value)
            currentTarget += 1

            if currentTarget > totalNumbers {
                // 게임 완료 - 보상 이미지 화면 표시
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if stageImage != nil || rewardImageName != nil {
                        showRewardScreen = true
                    } else {
                        SpeechService.shared.speak("와! 전부 다 했어요!")
                        showCompletionScreen = true
                    }
                }
            }
        } else {
            SpeechService.shared.speak("다시 해볼까?")
            shakeCounts[value, default: 0] += 1
        }
    }
}

#Preview("Number Pop Game") {
    NumberPopGameView(rewardImageName: nil)
        .padding()
}
