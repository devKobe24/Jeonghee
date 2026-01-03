//
//  AlbumView.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import SwiftUI
import PhotosUI

struct AlbumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var showGame = false
    @State private var currentStage = 1  // 현재 게임 단계 (1-5)
    @State private var usedImageIndices: Set<Int> = []  // 사용한 이미지 인덱스들
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if selectedImages.isEmpty {
                    // 사진이 선택되지 않았을 때
                    VStack(spacing: 20) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                        
                        Text("사진을 선택해주세요")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("최대 10장까지 선택 가능합니다")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // 선택된 사진들 표시
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                VStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(10)
                                    
                                    Text("\(index + 1)단계")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // 사진 선택 버튼
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    Text(selectedImages.isEmpty ? "사진 선택" : "사진 다시 선택")
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
                .padding(.horizontal)
                
                // 게임 시작 버튼
                if !selectedImages.isEmpty {
                    Button(action: {
                        currentStage = 1
                        usedImageIndices = []
                        showGame = true
                    }) {
                        Text("게임 시작")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
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
                            .cornerRadius(25)
                            .shadow(color: .green.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("앨범")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .onChange(of: selectedItems) { newItems in
                Task {
                    selectedImages = []
                    for item in newItems {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImages.append(image)
                        }
                    }
                    
                    // 선택한 이미지들을 앱 내부 저장소에 저장
                    if !selectedImages.isEmpty {
                        ImageStorageService.shared.saveImages(selectedImages)
                    }
                }
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
                                // 마지막 단계 완료 후 앨범 화면으로 돌아가기
                                showGame = false
                                currentStage = 1
                                usedImageIndices = []
                            }
                        }
                    )
                    .id(currentStage)  // 단계가 변경되면 뷰를 다시 생성
                }
            }
        }
    }
}

