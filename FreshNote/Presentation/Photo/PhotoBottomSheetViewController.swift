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
  private let albumButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "photo"), for: .normal)
    return button
  }()
  
  private let cameraButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "camera"), for: .normal)
    return button
  }()
  
  private let photoDeleteButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "trash"), for: .normal)
    return button
  }()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - Private Helpers
  private func setupLayout() {
    let stackView: UIStackView = {
      let sv = UIStackView()
      sv.axis = .vertical
      sv.distribution = .fillEqually
      sv.spacing = 2
      sv.alignment = .fill
      return sv
    }()
    _=[albumButton, cameraButton, photoDeleteButton].map { stackView.addArrangedSubview($0) }
    self.view.addSubview(stackView)
    
    stackView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
