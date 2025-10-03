//
//  ImageStorageManager.swift
//  TodayMenu
//
//  Created by Claude on 10/3/25.
//

import UIKit

enum ImageStorageType {
    case map        // 40px × 40px
    case calendar   // 60px × 60px
    case review     // 200px × 200px
    
    var size: CGSize {
        switch self {
        case .map: return CGSize(width: 40, height: 40)
        case .calendar: return CGSize(width: 60, height: 60)
        case .review: return CGSize(width: 200, height: 200)
        }
    }
    
    var folderName: String {
        switch self {
        case .map: return "MapPicture"
        case .calendar: return "CalendarPicture"
        case .review: return "ReviewPicture"
        }
    }
}

final class ImageStorageManager {
    
    static let shared = ImageStorageManager()
    
    private init() {
        createDirectories()
    }
    
    // MARK: - Public Methods
    
    /// 이미지 크기별 3가지 버전으로 저장 (Review 테이블 ID PK 으로 저장)
    /// - Parameters:
    ///   - images: 저장할 이미지 배열
    ///   - reviewId: Review 테이블의 PK (ObjectId)
    /// - Returns: Review 테이블에 저장할 파일명 배열
    func saveReviewImages(_ images: [UIImage], reviewId: String) -> [String] {
        var fileNames: [String] = []
        
        for (index, image) in images.enumerated() {
            let fileName = "\(reviewId)_\(index)"
            
            // 3가지 버전으로 저장
            let mapSuccess = saveImage(image, fileName: fileName, type: .map)
            let calendarSuccess = saveImage(image, fileName: fileName, type: .calendar)
            let reviewSuccess = saveImage(image, fileName: fileName, type: .review)
            
            // 모두 성공한 경우만 파일명 추가
            if mapSuccess && calendarSuccess && reviewSuccess {
                fileNames.append(fileName)
            }
        }
        
        return fileNames
    }
    
    // 특정 타입의 이미지 로드
    func loadImage(fileName: String, type: ImageStorageType) -> UIImage? {
        let fileURL = getImageURL(fileName: fileName, type: type)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("이미지 파일이 존재하지 않음: \(fileURL.path)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            print("이미지 로드 실패: \(fileURL.path)")
            return nil
        }
        
        return image
    }
    
    // 여러 이미지 로드
    func loadImages(fileNames: [String], type: ImageStorageType) -> [UIImage] {
        return fileNames.compactMap { loadImage(fileName: $0, type: type) }
    }
    
    // 리뷰 이미지 삭제 (3가지 타입 모두 삭제)
    func deleteReviewImages(fileNames: [String]) {
        for fileName in fileNames {
            deleteImage(fileName: fileName, type: .map)
            deleteImage(fileName: fileName, type: .calendar)
            deleteImage(fileName: fileName, type: .review)
        }
    }
}

// MARK: - Private Methods
extension ImageStorageManager {
    // Documents > Picture 디렉토리 구조 생성
    private func createDirectories() {
        let pictureDirectory = getPictureDirectory()
        
        // Picture 폴더가 없으면 생성
        if !FileManager.default.fileExists(atPath: pictureDirectory.path) {
            try? FileManager.default.createDirectory(at: pictureDirectory, withIntermediateDirectories: true)
        }
        
        // 각 서브 폴더 생성
        for type in [ImageStorageType.map, .calendar, .review] {
            let folderURL = pictureDirectory.appendingPathComponent(type.folderName)
            if !FileManager.default.fileExists(atPath: folderURL.path) {
                try? FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            }
        }
    }
    
    // 이미지를 리사이징하여 저장
    private func saveImage(_ image: UIImage, fileName: String, type: ImageStorageType) -> Bool {
        guard let resizedImage = resizeImage(image, targetSize: type.size),
              let data = resizedImage.jpegData(compressionQuality: 0.8) else {
            return false
        }
        
        let fileURL = getImageURL(fileName: fileName, type: type)
        
        do {
            try data.write(to: fileURL)
            return true
        } catch {
            print("이미지 저장 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    // 이미지 삭제
    private func deleteImage(fileName: String, type: ImageStorageType) -> Bool {
        let fileURL = getImageURL(fileName: fileName, type: type)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            print("이미지 삭제 실패: \(error.localizedDescription)")
            return false
        }
    }
    
    // 이미지 리사이즈
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // 비율을 유지하면서 리사이즈
        let scaleFactor = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    // Documents 디렉토리
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // Picture 디렉토리
    private func getPictureDirectory() -> URL {
        getDocumentsDirectory().appendingPathComponent("Picture")
    }
    
    // 이미지 파일 URL 생성
    private func getImageURL(fileName: String, type: ImageStorageType) -> URL {
        getPictureDirectory()
            .appendingPathComponent(type.folderName)
            .appendingPathComponent("\(fileName).jpg")
    }
}
