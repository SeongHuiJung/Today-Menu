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

final class CustomPhotoGalleryViewController: UIViewController {
    
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
        button.setTitle("추가", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    init(existingPhotoCount: Int) {
        self.existingCount = existingPhotoCount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        checkPhotoLibraryPermission()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(topBar)
        view.addSubview(collectionView)
        
        topBar.addSubview(closeButton)
        topBar.addSubview(titleLabel)
        topBar.addSubview(addButton)
        
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
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func setupBindings() {
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
        
        // 선택 개수 표시
        selectedPhotosRelay
            .map { "\($0.count)개 선택됨" }
            .subscribe(onNext: { [weak self] text in
                self?.addButton.setTitle(text.isEmpty ? "추가" : text, for: .normal)
            })
            .disposed(by: disposeBag)
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            loadPhotos()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self?.loadPhotos()
                    } else {
                        self?.dismiss(animated: true)
                    }
                }
            }
            
        default:
            dismiss(animated: true)
        }
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
                    title: "알림",
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
                    }
                }
            }
            
        default:
            let alert = UIAlertController(
                title: "카메라 권한 필요",
                message: "카메라 사용을 위해 권한이 필요합니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
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
}
