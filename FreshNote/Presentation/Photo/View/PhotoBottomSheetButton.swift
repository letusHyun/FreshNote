//
//  PhotoBottomSheetButton.swift
//  FreshNote
//
//  Created by SeokHyun on 11/23/24.
//

import UIKit

import SnapKit

final class PhotoBottomSheetButton: UIView {
  // MARK: - Properties
  private lazy var titleLabel: UILabel = {
    let lb = UILabel()
    lb.font = UIFont.pretendard(size: 16, weight: ._500)
    return lb
  }()
  
  private lazy var imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.backgroundColor = .clear
    return iv
  }()
  
  // MARK: - LifeCycle
  init(title: String, image: UIImage?, color: UIColor) {
    super.init(frame: .zero)
    
    self.setupComponents(title: title, image: image, color: color)
    self.setupLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Helpers
  private func setupComponents(title: String, image: UIImage?, color: UIColor) {
    self.titleLabel.text = title
    self.titleLabel.textColor = color
    self.imageView.image = image?.withTintColor(color, renderingMode: .alwaysOriginal)
  }
  
  private func setupLayout() {
    self.addSubview(titleLabel)
    self.addSubview(imageView)
    
    self.titleLabel.snp.makeConstraints {
      $0.leading.equalTo(24.5)
      $0.centerY.equalToSuperview()
    }
    
    self.imageView.snp.makeConstraints {
      $0.size.equalTo(28)
      $0.centerY.equalToSuperview()
      $0.centerX.equalTo(self.snp.trailing).inset(38.5)
    }
  }
}
