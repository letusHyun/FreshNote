//
//  PhotoBottomSheetViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/22/24.
//

import Combine
import UIKit

import SnapKit

final class PhotoBottomSheetViewController: UIViewController {
  // MARK: - Properties
  private let viewModel: any PhotoBottomSheetViewModel
  
  private let albumButton: PhotoBottomSheetButton = {
    let button = PhotoBottomSheetButton(
      title: "앨범에서 사진 선택",
      image: UIImage(systemName: "photo"),
      color: .black
    )
    
    return button
  }()
  
  private let cameraButton: PhotoBottomSheetButton = {
    let button = PhotoBottomSheetButton(
      title: "사진 찍기",
      image: UIImage(systemName: "camera"),
      color: .black
    )
    return button
  }()
  
  private let deleteButton: PhotoBottomSheetButton = {
    let button = PhotoBottomSheetButton(
      title: "사진 삭제",
      image: UIImage(systemName: "trash"),
      color: UIColor(fnColor: .red)
    )
    return button
  }()
  
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - LifeCycle
  init(viewModel: any PhotoBottomSheetViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    bind()
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - Private Helpers
  func bind() {
    self.albumButton.publisher(for: UITapGestureRecognizer())
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self?.present(imagePickerController, animated: true)
//        self?.viewModel.didTapAlbumButton()
      }
      .store(in: &self.subscriptions)
    
    self.cameraButton.publisher(for: UITapGestureRecognizer())
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.viewModel.didTapCameraButton()
      }
      .store(in: &self.subscriptions)
    
    self.deleteButton.publisher(for: UITapGestureRecognizer())
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.viewModel.didTapDeleteButton()
      }.store(in: &self.subscriptions)
  }
  
  
  private func setupLayout() {
    let stackView: UIStackView = {
      let sv = UIStackView()
      sv.axis = .vertical
      sv.distribution = .fillEqually
      sv.alignment = .fill
      return sv
    }()
    
    _=[self.albumButton, self.cameraButton, self.deleteButton].map { stackView.addArrangedSubview($0) }
    
    self.view.addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(20)
      $0.leading.trailing.equalToSuperview().inset(16.5)
      $0.bottom.equalToSuperview().inset(14)
    }
  }
}

extension PhotoBottomSheetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      let imageData = image.jpegData(compressionQuality: 0.8)
      picker.dismiss(animated: true)
      
      self.viewModel.didFinishPickingMediaWithInfo(data: imageData)
      // 여기서 받은 이미지를 vm -> Coordinator전달 후, coordinator에서 photoVM -> photoVC에게 전달
      // vm을 거쳐야 하므로, Data타입으로 변환해서 사용하는것이 좋을 듯
    }
  }
}
