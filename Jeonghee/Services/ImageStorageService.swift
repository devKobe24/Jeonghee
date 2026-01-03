//
//  ImageStorageService.swift
//  Jeonghee
//
//  Created by Kang MinSeong on 1/3/26.
//

import UIKit
import SwiftUI

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private let imagesDirectory: URL
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imagesDirectory = documentsPath.appendingPathComponent("SelectedImages")
        
        // 디렉토리 생성
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }
    
    // 이미지들을 저장
    func saveImages(_ images: [UIImage]) {
        // 기존 이미지 삭제
        clearAllImages()
        
        // 새 이미지들 저장
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let fileName = "image_\(index).jpg"
                let fileURL = imagesDirectory.appendingPathComponent(fileName)
                try? imageData.write(to: fileURL)
            }
        }
    }
    
    // 저장된 이미지들 불러오기
    func loadImages() -> [UIImage] {
        var images: [UIImage] = []
        
        guard let files = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else {
            return images
        }
        
        let imageFiles = files.filter { $0.pathExtension == "jpg" || $0.pathExtension == "png" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        
        for fileURL in imageFiles {
            if let imageData = try? Data(contentsOf: fileURL),
               let image = UIImage(data: imageData) {
                images.append(image)
            }
        }
        
        return images
    }
    
    // 모든 이미지 삭제
    func clearAllImages() {
        guard let files = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else {
            return
        }
        
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }
    
    // 무작위로 이미지 선택 (제외할 인덱스 포함)
    func selectRandomImage(excluding: Int? = nil) -> UIImage? {
        let images = loadImages()
        guard !images.isEmpty else { return nil }
        
        var availableIndices = Array(0..<images.count)
        
        // 제외할 인덱스가 있으면 제거
        if let excluding = excluding, excluding < images.count {
            availableIndices.removeAll { $0 == excluding }
        }
        
        guard !availableIndices.isEmpty else { return nil }
        
        let randomIndex = availableIndices.randomElement() ?? availableIndices[0]
        return images[randomIndex]
    }
    
    // 무작위로 이미지와 인덱스 선택 (제외할 인덱스 포함)
    func selectRandomImageWithIndex(excluding: Int? = nil) -> (image: UIImage, index: Int)? {
        let images = loadImages()
        guard !images.isEmpty else { return nil }
        
        var availableIndices = Array(0..<images.count)
        
        // 제외할 인덱스가 있으면 제거
        if let excluding = excluding, excluding < images.count {
            availableIndices.removeAll { $0 == excluding }
        }
        
        guard !availableIndices.isEmpty else { return nil }
        
        let randomIndex = availableIndices.randomElement() ?? availableIndices[0]
        return (images[randomIndex], randomIndex)
    }
}

