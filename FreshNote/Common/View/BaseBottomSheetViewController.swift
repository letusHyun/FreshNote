//
//  BaseBottomSheetViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/20/24.
//

import Combine
import UIKit

class BaseBottomSheetViewController: BaseViewController {
  // MARK: - Properties
  private let dimmedView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    return view
  }()
  
  private let contentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 10
    view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    view.clipsToBounds = true
    return view
  }()
  
  private var contentViewTopConstraint: NSLayoutConstraint?
  
  // 외부에서 해당 프로퍼티를 사용해서 bottomSheet의
  var defaultHeight: CGFloat = 300
  
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupLayout()
    self.setupTapGesture()
    self.bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.showBottomSheet()
  }
  
  // MARK: - setupUI
  override func setupLayout() {
    self.view.addSubview(self.dimmedView)
    self.view.addSubview(self.contentView)
    
    self.dimmedView.translatesAutoresizingMaskIntoConstraints = false
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    
    let topConstant: CGFloat = self.view.safeAreaInsets.bottom + self.view.safeAreaLayoutGuide.layoutFrame.height
    self.contentViewTopConstraint = self.contentView.topAnchor.constraint(
      equalTo: self.view.safeAreaLayoutGuide.topAnchor,
      constant: topConstant
    )
    
    guard let contentViewTopConstraint = self.contentViewTopConstraint else { return }
  
    NSLayoutConstraint.activate([
      self.dimmedView.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.dimmedView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.dimmedView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.dimmedView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      
      self.contentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.contentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.contentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      contentViewTopConstraint,
    ])
  }
  
  // MARK: - Private Helpers
  private func bind() {
    self.dimmedView.publisher(for: UITapGestureRecognizer())
      .compactMap { $0 as?UITapGestureRecognizer }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] sender in
        self?.hideBottomSheet()
      }
      .store(in: &self.subscriptions)
  }
  
  private func setupTapGesture() {
    self.dimmedView.isUserInteractionEnabled = true
  }
  
  private func hideBottomSheet() {
    let safeAreaHeight = self.view.safeAreaLayoutGuide.layoutFrame.height
    let bottomPadding = self.view.safeAreaInsets.bottom
    
    self.contentViewTopConstraint?.constant = safeAreaHeight + bottomPadding
    
    UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseIn, animations: {
      self.dimmedView.alpha = 0.0
      self.view.layoutIfNeeded()
    }) { _ in
      // completion 클로저
    }
  }
  
  private func showBottomSheet() {
    let height: CGFloat = self.view.safeAreaLayoutGuide.layoutFrame.height
    let bottomPadding: CGFloat = self.view.safeAreaInsets.bottom
    
    self.contentViewTopConstraint?.constant = (height + bottomPadding) - self.defaultHeight
    
    UIView.animate(withDuration: 0.25, delay: .zero, options: .curveEaseIn, animations: {
      self.dimmedView.alpha = 0.7
      self.view.layoutIfNeeded()
    }, completion: nil)
  }
}
