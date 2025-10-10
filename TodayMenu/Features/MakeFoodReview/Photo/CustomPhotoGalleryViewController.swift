//
//  CustomPhotoGalleryViewController.swift
//  TodayMenu
//
//  Created by 정성희 on 10/3/25.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

final class CustomPhotoGalleryViewController: BaseViewController {
    
    private let disposeBag = DisposeBag()
    private var allPhotos: PHFetchResult<PHAsset>?
    private let selectedPhotosRelay = BehaviorRelay<[PHAsset]>(value: [])
    private let maxSelection = 5
    private let existingCount: Int
    
    var onPhotosSelected: (([UIImage]) -> Void)?
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 2
        let width = (UIScreen.main.bounds.width - spacing * 4) / 3
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.register(CameraCell.self, forCellWithReuseIdentifier: CameraCell.identifier)
        cv.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.identifier)
        return cv
    }()
    
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 항목"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("선택", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.point2, for: .normal)
        button.setTitleColor(.systemGray3, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private let limitedAccessBanner: UIView = {
        let view = UIView()
        view.backgroundColor = .customGray0
        view.isHidden = true
        return view
    }()
    
    private let bannerLabel: UILabel = {
        let label = UILabel()
        label.text = "모든 사진 접근 권한을 허용하면 더 편하게 사진을 올릴 수 있어요."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let settingButton = RadiusButton(title: "사진 접근 권한 허용하기", size: 13, textColor: .point2, backgroundColor: .customGray1, cornerRadius: 15)
    
    init(existingPhotoCount: Int) {
        self.existingCount = existingPhotoCount
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPhotoLibraryPermission()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.addSubview(limitedAccessBanner)
        view.addSubview(collectionView)
        
        topBar.addSubview(closeButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(addButton)
        
        limitedAccessBanner.addSubview(bannerLabel)
        limitedAccessBanner.addSubview(settingButton)
        
        topBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        limitedAccessBanner.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(0)  // 초기에는 숨김
        }
        
        bannerLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
        }
        
        settingButton.snp.makeConstraints {
            $0.top.equalTo(bannerLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(10)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(limitedAccessBanner.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func bind() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .withLatestFrom(selectedPhotosRelay)
            .subscribe(onNext: { [weak self] assets in
                self?.convertAssetsToImages(assets)
            })
            .disposed(by: disposeBag)
        
        // 선택 개수에 따른 버튼 활성화/비활성화
        selectedPhotosRelay
            .map { $0.count > 0 }
            .subscribe(onNext: { [weak self] isEnabled in
                self?.addButton.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
        
        // 설정 버튼 탭
        settingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })
            .disposed(by: disposeBag)
    }

    private func showPhotoPermissionAlert() {
        
        let alert = UIAlertController(
            title: "접근 권한 안내",
            message: "사진을 선택하기 위해 설정에서 갤러리 접근 권한을 허용해 주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "설정", style: .default) { [weak self] _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "접근 권한 안내",
            message: "카메라를 사용하기 위해 설정에서 카메라 접근 권한을 허용해 주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "설정", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func loadPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        collectionView.reloadData()
    }
    
    private func convertAssetsToImages(_ assets: [PHAsset]) {
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        var images: [UIImage] = []
        
        for asset in assets {
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        
        onPhotosSelected?(images)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension CustomPhotoGalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (allPhotos?.count ?? 0) + 1 // +1 for camera cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 첫 번째 셀은 카메라 셀
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CameraCell.identifier, for: indexPath) as! CameraCell
            return cell
        }
        
        // 나머지는 사진 셀
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as! PhotoCell
        
        let photoIndex = indexPath.item - 1
        if let asset = allPhotos?.object(at: photoIndex) {
            cell.configure(with: asset)
            
            let selectedAssets = selectedPhotosRelay.value
            let isSelected = selectedAssets.contains(asset)
            let selectionIndex = selectedAssets.firstIndex(of: asset)
            cell.updateSelection(isSelected: isSelected, index: selectionIndex)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CustomPhotoGalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // 카메라 셀 탭
        if indexPath.item == 0 {
            presentCamera()
            return
        }
        
        // 사진 셀 탭
        let photoIndex = indexPath.item - 1
        guard let asset = allPhotos?.object(at: photoIndex) else { return }
        
        var selectedAssets = selectedPhotosRelay.value
        
        if let index = selectedAssets.firstIndex(of: asset) {
            // 이미 선택된 사진 -> 선택 해제
            selectedAssets.remove(at: index)
        } else {
            // 새로 선택
            if selectedAssets.count + existingCount < maxSelection {
                selectedAssets.append(asset)
            } else {
                // 최대 개수 초과
                let alert = UIAlertController(
                    title: "안내",
                    message: "사진은 최대 \(maxSelection)장까지 선택할 수 있습니다.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                present(alert, animated: true)
                return
            }
        }
        
        selectedPhotosRelay.accept(selectedAssets)
        collectionView.reloadData()
    }
    
    private func presentCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showCamera()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showCamera()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            showCameraPermissionAlert()
            
        @unknown default:
            showCameraPermissionAlert()
        }
    }
    
    private func showCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CustomPhotoGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        // 사진을 포토 라이브러리에 저장
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    // 사진 목록 새로고침
                    self?.loadPhotos()
                    
                    // 방금 찍은 사진을 자동 선택
                    if let firstAsset = self?.allPhotos?.firstObject {
                        var selectedAssets = self?.selectedPhotosRelay.value ?? []
                        if selectedAssets.count + (self?.existingCount ?? 0) < (self?.maxSelection ?? 5) {
                            selectedAssets.append(firstAsset)
                            self?.selectedPhotosRelay.accept(selectedAssets)
                            self?.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            loadPhotos()
            hideLimitedAccessBanner()
            
        case .limited:
            loadPhotos()
            showLimitedAccessBanner()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.loadPhotos()
                        self?.hideLimitedAccessBanner()
                    } else if status == .limited {
                        self?.loadPhotos()
                        self?.showLimitedAccessBanner()
                    } else {
                        self?.showPhotoPermissionAlert()
                    }
                }
            }
            
        case .denied, .restricted:
            showPhotoPermissionAlert()
            
        @unknown default:
            showPhotoPermissionAlert()
        }
    }
    
    private func showLimitedAccessBanner() {
        limitedAccessBanner.isHidden = false
        
        limitedAccessBanner.snp.updateConstraints {
            $0.height.equalTo(80)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideLimitedAccessBanner() {
        limitedAccessBanner.snp.updateConstraints {
            $0.height.equalTo(0)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.limitedAccessBanner.isHidden = true
        }
    }
}
