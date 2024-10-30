//
//  OnboardingViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 10/19/24.
//

import UIKit

final class OnboardingViewController: BaseViewController {
  // MARK: - Properties
  private let freshNoteTitle: FreshNoteTitleView = {
    let view = FreshNoteTitleView()
    return view
  }()
  
  private lazy var collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = .zero
    let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    cv.dataSource = self
    cv.delegate = self
    cv.isPagingEnabled = true
    cv.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.id)
    cv.bounces = false
    cv.showsHorizontalScrollIndicator = false
    return cv
  }()
  
  private lazy var pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.numberOfPages = viewModel.dataSourceCount()
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = UIColor(hex: "#B8B5B5")
    pageControl.currentPageIndicatorTintColor = UIColor(fnColor: .text3)
    pageControl.isUserInteractionEnabled = false
    return pageControl
  }()
  
  private let buttonStackView: UIStackView = {
    let sv = UIStackView()
    sv.axis = .vertical
    sv.distribution = .fillEqually
    sv.spacing = 12
    return sv
  }()
  
  private let kakaoLoginButton: LoginButton = {
    let button = LoginButton(
      title: "카카오 로그인",
      imagePath: "kakaoLoginLogo",
      titleColor: .black,
      backgroundColor: UIColor(hex: "#FEE500")
    )
    button.isHidden = true
    button.alpha = 0
    return button
  }()
  
  private let appleLoginButton: LoginButton = {
    let button = LoginButton(
      title: "Apple 로그인",
      imagePath: "kakaoLoginLogo",
      titleColor: .white,
      backgroundColor: .black
    )
    button.isHidden = true
    button.alpha = 0
    return button
  }()
  
  private let viewModel: any OnboardingViewModel
  
  // MARK: - LifeCycle
  init(viewModel: any OnboardingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addTargets()
    setNavigationConfiguration()
  }
  
  // MARK: - SetupUI
  override func setupLayout() {
    view.addSubview(freshNoteTitle)
    view.addSubview(collectionView)
    view.addSubview(pageControl)
//    view.addSubview(buttonStackView)
    view.addSubview(kakaoLoginButton)
    
    freshNoteTitle.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    kakaoLoginButton.translatesAutoresizingMaskIntoConstraints = false
    buttonStackView.translatesAutoresizingMaskIntoConstraints = false
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      freshNoteTitle.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 30),
      freshNoteTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ] + [
      collectionView.topAnchor.constraint(equalTo: freshNoteTitle.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -92)
    ] + [
      pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
      pageControl.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
    ] + [
      kakaoLoginButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
      kakaoLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26.5),
      kakaoLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26.5),
      kakaoLoginButton.heightAnchor.constraint(equalToConstant: 60)
    ])
  }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return viewModel.numberOfItemsInSection(sectionIndex: section)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    guard let onboardingCell = collectionView.dequeueReusableCell(
      withReuseIdentifier: OnboardingCell.id,
      for: indexPath
    ) as? OnboardingCell else { return UICollectionViewCell() }
    
    let info = viewModel.cellForItemAt(indexPath: indexPath)
    onboardingCell.configure(with: info)
    
    return onboardingCell
  }
}

// MARK: - UICollectionViewDelegate
extension OnboardingViewController: UICollectionViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let currentPageIndex = Int(scrollView.contentOffset.x / scrollView.frame.width)
    pageControl.currentPage = currentPageIndex
    
    if currentPageIndex == viewModel.dataSourceCount() - 1 {
      configureLoginButtonAnimation()
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return .init(width: collectionView.frame.width, height: collectionView.frame.height)
  }
}

extension OnboardingViewController {
  private func configureLoginButtonAnimation() {
    collectionView.isScrollEnabled = false
    pageControl.isHidden = true
    kakaoLoginButton.isHidden = false
    UIView.animate(withDuration: 1.5) {
      self.kakaoLoginButton.alpha = 1
    }
  }
}

// MARK: - Prvate Helpers
extension OnboardingViewController {
  private func addTargets() {
    kakaoLoginButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
  }
  
  private func setNavigationConfiguration() {
    navigationController?.navigationBar.isHidden = true
  }
}

// MARK: - Actions
private extension OnboardingViewController {
  @objc func startButtonTapped() {
    viewModel.didTapLoginButton()
  }
}
