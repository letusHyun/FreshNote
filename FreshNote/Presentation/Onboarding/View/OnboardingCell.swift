//
//  OnboardingCell.swift
//  FreshNote
//
//  Created by SeokHyun on 10/20/24.
//

import UIKit
import Lottie

final class OnboardingCell: UICollectionViewCell {
  // MARK: - Properties
  static var id: String {
    return String(describing: Self.self)
  }
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = .pretendard(size: 16, weight: ._600)
    label.textColor = UIColor(fnColor: .gray3)
    label.numberOfLines = 0
    label.textAlignment = .center
    return label
  }()
  
  private let lottieView: LottieAnimationView = {
    let view = LottieAnimationView(animation: nil)
    view.contentMode = .scaleAspectFit
    view.loopMode = .loop
    return view
  }()
  
  // MARK: - LifeCycle
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Configure
extension OnboardingCell {
  func configure(with info: OnboardingCellInfo) {
    descriptionLabel.text = info.description
    lottieView.stop()
    lottieView.animation = LottieAnimation.named(info.lottieName)
    lottieView.play()
  }
}

// MARK: - Private Helpers
private extension OnboardingCell {
  func setupUI() {
    setupLayout()
  }
  
  func setupLayout() {
    contentView.addSubview(descriptionLabel)
    contentView.addSubview(lottieView)
    
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    lottieView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate(
      [
        lottieView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 70),
        lottieView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        lottieView.widthAnchor.constraint(equalToConstant: 300),
        lottieView.heightAnchor.constraint(equalTo: lottieView.widthAnchor),
        lottieView.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -50)
      ]
      +
      [
        descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
      ]
    )
  }
}
