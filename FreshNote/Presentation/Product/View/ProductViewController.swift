//
//  ProductViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/14/24.
//

import Combine
import UIKit

final class ProductViewController: BaseViewController {
  // MARK: - Properties
  private let viewModel: any ProductViewModel
  
  private let backButton = NavigationBackButton()
  
  private var subscriptions = Set<AnyCancellable>()
  
  private let placeholderTitleView
  
  // MARK: - LifeCycle
  init(viewModel: any ProductViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    
    bind(to: self.viewModel)
  }
  
  // MARK: - SetupUI
  override func setupLayout() {
    
  }
}

private extension ProductViewController {
  // MARK: - Bind
  func bind(to viewModel: any ProductViewModel) {
    
  }
  
  // MARK: - Actions
  func bindAction() {
    self.backButton.publisher(for: .touchUpInside)
      .sink { [weak self] _ in
        self?.viewModel.didTapBackButton()
      }
      .store(in: &self.subscriptions)
  }
}

// MARK: - Private Helpers
extension ProductViewController {
  private func setupNavigationBar() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
  }
}
