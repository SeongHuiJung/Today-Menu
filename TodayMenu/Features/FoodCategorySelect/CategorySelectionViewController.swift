//
//  CategorySelectionViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 10/7/25.
//

import UIKit
import RxSwift
import RxCocoa

final class CategorySelectionViewController: BaseViewController {

    private let mainView = CategorySelectionView()
    private let viewModel = CategorySelectionViewModel()
    private let disposeBag = DisposeBag()

    // 카테고리 선택 콜백
    var onCategorySelected: ((String, String) -> Void)?

    private var categorySections: [CategorySelectionViewModel.CategorySection] = []
    private var isScrollingProgrammatically = false
    private let scrollSectionSubject = PublishSubject<Int>()
    private var selectedCuisineIndex: Int = 0 // 현재 선택된 대분류 인덱스
    private var isInitialLoad = true // 초기 로드 플래그
    private var selectedCategoryIndexPath: IndexPath? // 현재 선택된 중분류 인덱스

    private let selectButton = UIBarButtonItem(title: "선택", style: .plain, target: nil, action: nil)
    private let selectButtonTapSubject = PublishSubject<Void>()

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupCollectionView()
        loadInitialData()
        bind()
    }

    private func loadInitialData() {
        categorySections = viewModel.getCategorySections()

        // 초기 선택 인덱스는 0 (한식)
        selectedCuisineIndex = 0
    }

    override func configureView() {
        super.configureView()
        title = "음식 분류 설정"
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.fontBlack]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .fontBlack

        // 우측 선택 버튼 추가
        navigationItem.rightBarButtonItem = selectButton

        // 선택 버튼 Rx 바인딩
        selectButton.rx.tap
            .bind(to: selectButtonTapSubject)
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        mainView.cuisineTableView.rowHeight = 60
    }

    private func setupCollectionView() {
        mainView.categoryCollectionView.delegate = self
        mainView.categoryCollectionView.dataSource = self
    }
}

// MARK: - Bind
extension CategorySelectionViewController {
    private func bind() {
        let cuisineSelectedSubject = PublishSubject<Int>()
        let categorySelectedSubject = PublishSubject<IndexPath>()

        let input = CategorySelectionViewModel.Input(
            cuisineSelected: cuisineSelectedSubject.asObservable(),
            collectionViewDidScroll: scrollSectionSubject.asObservable(),
            categorySelected: categorySelectedSubject.asObservable(),
            selectButtonTapped: selectButtonTapSubject.asObservable()
        )

        let output = viewModel.transform(input)

        // 대분류 목록 바인딩
        output.cuisines
            .drive(mainView.cuisineTableView.rx.items(
                cellIdentifier: CuisineTableViewCell.identifier,
                cellType: CuisineTableViewCell.self
            )) { [weak self] index, cuisine, cell in
                let isSelected = index == self?.selectedCuisineIndex
                cell.configure(title: cuisine, isSelected: isSelected)
            }
            .disposed(by: disposeBag)

        // 중분류 섹션 데이터 저장
        output.categories
            .drive(onNext: { [weak self] sections in
                self?.categorySections = sections
                self?.mainView.categoryCollectionView.reloadData()

                // 초기 로드 완료 후 0.5초 뒤에 스크롤 감지 활성화
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.isInitialLoad = false
                }
            })
            .disposed(by: disposeBag)

        // 대분류 선택 변경 시 테이블뷰 업데이트
        output.selectedCuisineIndex
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                self.selectedCuisineIndex = index
                self.mainView.cuisineTableView.reloadData()
            })
            .disposed(by: disposeBag)

        // 대분류 선택 시 컬렉션뷰 스크롤
        output.scrollToSection
            .emit(onNext: { [weak self] section in
                guard let self = self,
                      section < self.categorySections.count,
                      !self.categorySections.isEmpty else { return }

                self.isScrollingProgrammatically = true

                // 레이아웃 계산 후 헤더 위치로 스크롤
                self.mainView.categoryCollectionView.layoutIfNeeded()

                let collectionView = self.mainView.categoryCollectionView
                let headerRect = self.getHeaderRect(for: section)
                var offsetY = headerRect.origin.y

                // 최대 스크롤 가능한 오프셋 계산
                let maxOffsetY = max(0, collectionView.contentSize.height - collectionView.bounds.height + collectionView.contentInset.bottom)

                // 최대 오프셋을 초과하지 않도록 제한
                offsetY = min(offsetY, maxOffsetY)

                collectionView.setContentOffset(
                    CGPoint(x: 0, y: offsetY),
                    animated: true
                )

                // 0.5초 후 플래그 해제
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isScrollingProgrammatically = false
                }
            })
            .disposed(by: disposeBag)

        // 테이블뷰 선택 이벤트
        mainView.cuisineTableView.rx.itemSelected
            .map { $0.row }
            .bind(to: cuisineSelectedSubject)
            .disposed(by: disposeBag)

        // 중분류 선택 이벤트
        mainView.categoryCollectionView.rx.itemSelected
            .bind(to: categorySelectedSubject)
            .disposed(by: disposeBag)

        // 선택된 중분류 IndexPath 관리 (UI 업데이트용)
        output.selectedCategoryIndexPath
            .drive(onNext: { [weak self] newIndexPath in
                guard let self = self else { return }

                // 이전 선택 해제
                if let previousIndexPath = self.selectedCategoryIndexPath {
                    self.selectedCategoryIndexPath = nil
                    self.mainView.categoryCollectionView.reloadItems(at: [previousIndexPath])
                }

                // 새로운 선택 저장 및 업데이트
                if let newIndexPath = newIndexPath {
                    self.selectedCategoryIndexPath = newIndexPath
                    self.mainView.categoryCollectionView.reloadItems(at: [newIndexPath])
                }
            })
            .disposed(by: disposeBag)

        // 선택 버튼 활성화 상태 바인딩
        output.isSelectButtonEnabled
            .drive(selectButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // 선택 완료 시 처리
        output.dismissWithCategory
            .emit(onNext: { [weak self] result in
                guard let self = self else { return }
                let (cuisine, category) = result
                print("선택된 음식: \(cuisine) > \(category)")

                // 콜백으로 선택된 카테고리 전달
                self.onCategorySelected?(cuisine, category)
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension CategorySelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60) / 2 // 2열
        return CGSize(width: width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }

    // 스크롤 시 현재 보이는 섹션 감지
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 초기 로드 중에는 무시
        guard !isInitialLoad else { return }

        // 프로그래밍 방식 스크롤 중에는 무시
        guard !isScrollingProgrammatically else { return }

        // 데이터가 로드되지 않았으면 무시
        guard !categorySections.isEmpty else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let boundsHeight = scrollView.bounds.height

        // 현재 스크롤 진행도 계산 (0.0 ~ 1.0)
        let maxScrollY = max(0, contentHeight - boundsHeight)
        let scrollProgress = maxScrollY > 0 ? min(offsetY / maxScrollY, 1.0) : 0

        // 기준점 비율을 동적으로 계산 (상단: 0.05, 하단: 0.9)
        let criteriaRatio = 0.05 + (scrollProgress * 0.85)

        // 기준점의 절대 Y 위치
        let criteriaY = offsetY + (boundsHeight * criteriaRatio)

        var currentSection = 0

        // 기준점을 지나간 섹션 찾기
        for section in 0..<categorySections.count {
            let headerRect = getHeaderRect(for: section)

            // 헤더 위치가 기준점보다 아래에 있으면 이전 섹션 유지
            if headerRect.origin.y > criteriaY {
                break
            }

            currentSection = section
        }

        // Subject로 섹션 전달
        scrollSectionSubject.onNext(currentSection)
    }

    // 섹션 헤더의 위치 계산
    private func getHeaderRect(for section: Int) -> CGRect {
        guard section < categorySections.count else { return .zero }

        let collectionView = mainView.categoryCollectionView

        // 레이아웃이 준비되지 않았으면 .zero 반환
        guard collectionView.numberOfSections > section else { return .zero }

        let layoutAttributes = collectionView.layoutAttributesForSupplementaryElement(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: section)
        )
        return layoutAttributes?.frame ?? .zero
    }
}

// MARK: - UICollectionViewDataSource
extension CategorySelectionViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categorySections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categorySections[section].categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CategoryCollectionViewCell.identifier,
            for: indexPath
        ) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        let category = categorySections[indexPath.section].categories[indexPath.item]
        let isSelected = (indexPath == selectedCategoryIndexPath)
        cell.configure(title: category, isSelected: isSelected)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: CategoryHeaderView.identifier,
                for: indexPath
              ) as? CategoryHeaderView else {
            return UICollectionReusableView()
        }

        let cuisine = categorySections[indexPath.section].cuisine
        header.configure(title: cuisine, icon: UIImage(systemName: "fork.knife"))
        return header
    }
}
