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
}
