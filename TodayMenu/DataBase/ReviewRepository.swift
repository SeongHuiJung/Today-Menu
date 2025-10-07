//
//  ReviewRepository.swift
//  TodayMenu
//
//  Created by 정성희 on 9/29/25.
//

import Foundation
import RealmSwift
import RxSwift

final class ReviewRepository {
    
    private let realm: Realm
    
    init() {
        do {
            self.realm = try Realm()
            print("Realm Location: \(realm.configuration.fileURL!)")
        } catch {
            fatalError("Realm 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Create
    func saveReview(_ review: Review) -> Observable<Result<Void, Error>> {
        return Observable.create { observer in
            do {
                try self.realm.write {
                    self.realm.add(review)
                }
                observer.onNext(.success(()))
                observer.onCompleted()
            } catch {
                observer.onNext(.failure(error))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Read
    func fetchAllReviews() -> Observable<[Review]> {
        return Observable.create { observer in
            let results = self.realm.objects(Review.self)
            let reviews = Array(results)
            observer.onNext(reviews)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func fetchReview(by id: ObjectId) -> Observable<Review?> {
        return Observable.create { observer in
            let review = self.realm.object(ofType: Review.self, forPrimaryKey: id)
            observer.onNext(review)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    
    func fetchReviewsByRestaurantId(restaurantId: String) -> Observable<[Review]> {
        return Observable.create { observer in
            let reviews = self.realm.objects(Review.self).where {
                $0.restaurant.restaurantId == restaurantId
            }
            observer.onNext(Array(reviews))
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    // MARK: - Update
    func updateReview(_ review: Review) -> Observable<Result<Void, Error>> {
        return Observable.create { observer in
            do {
                try self.realm.write {
                    review.updatedAt = Date()
                    self.realm.add(review, update: .modified)
                }
                observer.onNext(.success(()))
                observer.onCompleted()
            } catch {
                observer.onNext(.failure(error))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Delete
    func deleteReview(_ review: Review) -> Observable<Result<Void, Error>> {
        return Observable.create { observer in
            // 기기에 저장된 사진 먼저 삭제
            let photoFileNames = Array(review.photos)
            ImageStorageManager.shared.deleteReviewImages(fileNames: photoFileNames)

            // Realm 에서 사진 이름 삭제
            do {
                try self.realm.write {
                    self.realm.delete(review)
                }
                observer.onNext(.success(()))
                observer.onCompleted()
            } catch {
                observer.onNext(.failure(error))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    // MARK: - RecommendHistory 연동
    /// RecommendHistory의 reviewId 업데이트
    func updateRecommendHistoryReviewId(recommendHistoryId: ObjectId, reviewId: ObjectId) -> Observable<Result<Void, Error>> {
        return Observable.create { observer in
            do {
                guard let history = self.realm.object(ofType: RecommendHistory.self, forPrimaryKey: recommendHistoryId) else {
                    observer.onNext(.failure(NSError(domain: "ReviewRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "RecommendHistory를 찾을 수 없음"])))
                    observer.onCompleted()
                    return Disposables.create()
                }

                try self.realm.write {
                    history.reviewId = reviewId.stringValue
                }
                print("RecommendHistory reviewId 업데이트: \(reviewId)")
                observer.onNext(.success(()))
                observer.onCompleted()
            } catch {
                observer.onNext(.failure(error))
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
