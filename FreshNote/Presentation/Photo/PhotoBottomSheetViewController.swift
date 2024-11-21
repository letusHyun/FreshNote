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
  
  private func setupLayout() {
    self.view.addSubview(self.albumButton)
    self.view.addSubview(self.cameraButton)
    self.view.addSubview(self.photoDeleteButton)
    
    self.albumButton.snp.makeConstraints {
      $0.top.equalToSuperview().inset(30)
      $0.leading.equalToSuperview().inset(10)
      $0.width.height.equalTo(40)
    }
    
    self.cameraButton.snp.makeConstraints {
      $0.top.equalTo(self.albumButton.snp.bottom)
      $0.leading.equalTo(self.albumButton)
      $0.width.height.equalTo(albumButton)
    }
    
    self.photoDeleteButton.snp.makeConstraints {
      $0.top.equalTo(self.cameraButton.snp.bottom)
      $0.leading.equalTo(self.albumButton)
      $0.width.height.equalTo(40)
      $0.bottom.equalToSuperview()
    }
  }
}
