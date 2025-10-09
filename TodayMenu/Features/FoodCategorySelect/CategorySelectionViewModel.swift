//
//  CategorySelectionViewModel.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CategorySelectionViewModel {

    struct Input {
        let cuisineSelected: Observable<Int> // 대분류 테이블뷰 선택
        let collectionViewDidScroll: Observable<Int> // 컬렉션뷰 스크롤로 감지된 섹션
        let categorySelected: Observable<IndexPath> // 중분류 셀 선택
        let selectButtonTapped: Observable<Void> // 선택 버튼 탭
    }

    struct Output {
        let cuisines: Driver<[String]> // 대분류 목록
        let categories: Driver<[CategorySection]> // 중분류 섹션 목록
        let selectedCuisineIndex: Driver<Int> // 선택된 대분류 인덱스
        let scrollToSection: Signal<Int> // 컬렉션뷰 스크롤할 섹션
        let selectedCategoryIndexPath: Driver<IndexPath?> // 선택된 중분류 IndexPath
        let isSelectButtonEnabled: Driver<Bool> // 선택 버튼 활성화 여부
        let dismissWithCategory: Signal<String> // 카테고리 선택 완료 후 dismiss
    }

    struct CategorySection {
        let cuisine: String
        let categories: [String]
    }

    private let disposeBag = DisposeBag()
    private let selectedCuisineIndexRelay = BehaviorRelay<Int>(value: 0)
    private let selectedCategoryIndexPathRelay = BehaviorRelay<IndexPath?>(value: nil)

    // 음식 데이터
    private let cuisines = ["한식", "중식", "일식", "양식", "멕시코식", "베트남식", "태국식"]
    private let categoryData: [String: [String]] = [
        "한식": ["비빔밥", "김치찌개", "불고기", "냉면", "삼겹살", "떡볶이", "육회", "김밥"],
        "중식": ["짜장면", "짬뽕", "탕수육", "마라탕", "마라샹궈"],
        "일식": ["라멘", "초밥", "돈까스", "우동"],
        "양식": ["피자", "파스타", "스테이크"],
        "멕시코식": ["타코"],
        "베트남식": ["쌀국수", "반미"],
        "태국식": ["팟타이"]
    ]

    func getCategorySections() -> [CategorySection] {
        return cuisines.map { cuisine in
            CategorySection(
                cuisine: cuisine,
                categories: categoryData[cuisine] ?? []
            )
        }
    }

    func transform(_ input: Input) -> Output {
        // 대분류 선택 시 해당 섹션으로 스크롤
        let scrollToSection = input.cuisineSelected
            .do(onNext: { [weak self] index in
                self?.selectedCuisineIndexRelay.accept(index)
            })
            .asSignal(onErrorSignalWith: .empty())

        // 컬렉션뷰 스크롤 시 현재 보이는 섹션에 맞춰 대분류 선택 변경
        input.collectionViewDidScroll
            .distinctUntilChanged()
            .bind(to: selectedCuisineIndexRelay)
            .disposed(by: disposeBag)

        // 중분류 셀 선택 시 IndexPath 저장
        input.categorySelected
            .bind(to: selectedCategoryIndexPathRelay)
            .disposed(by: disposeBag)

        // 선택 버튼 활성화 여부 (중분류 선택 여부에 따라)
        let isSelectButtonEnabled = selectedCategoryIndexPathRelay
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)

        // 선택 버튼 탭 시 선택된 카테고리 반환
        let dismissWithCategory = input.selectButtonTapped
            .withLatestFrom(selectedCategoryIndexPathRelay)
            .compactMap { [weak self] indexPath -> String? in
                guard let self = self,
                      let indexPath = indexPath,
                      indexPath.section < self.cuisines.count else {
                    return nil
                }
                let cuisine = self.cuisines[indexPath.section]
                let categories = self.categoryData[cuisine] ?? []
                guard indexPath.item < categories.count else { return nil }
                return categories[indexPath.item]
            }
            .asSignal(onErrorSignalWith: .empty())

        // 섹션 데이터 생성
        let sections = getCategorySections()

        return Output(
            cuisines: Driver.just(cuisines),
            categories: Driver.just(sections),
            selectedCuisineIndex: selectedCuisineIndexRelay.asDriver(),
            scrollToSection: scrollToSection,
            selectedCategoryIndexPath: selectedCategoryIndexPathRelay.asDriver(),
            isSelectButtonEnabled: isSelectButtonEnabled,
            dismissWithCategory: dismissWithCategory
        )
    }
}
