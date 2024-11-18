//
//  OnboardingViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 10/19/24.
//

import UIKit
import AuthenticationServices
import Combine
import CryptoKit
import FirebaseAuth

final class OnboardingViewController: BaseViewController {
  // MARK: - Properties
  private var subscriptions = Set<AnyCancellable>()
  
  private let freshNoteTitle: FreshNoteTitleView = {
    let view = FreshNoteTitleView()
    return view
  }()
  
  private let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    flowLayout.minimumLineSpacing = .zero
    let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
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
    pageControl.currentPageIndicatorTintColor = UIColor(fnColor: .gray3)
    pageControl.isUserInteractionEnabled = false
    return pageControl
  }()
  
  private let appleLoginButton: ASAuthorizationAppleIDButton = {
    let button = ASAuthorizationAppleIDButton(
      authorizationButtonType: .signIn,
      authorizationButtonStyle: .black
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
    setupCollectionView()
  }
  
  // MARK: - SetupUI
  override func setupLayout() {
    view.addSubview(freshNoteTitle)
    view.addSubview(collectionView)
    view.addSubview(pageControl)
    view.addSubview(appleLoginButton)
    
    freshNoteTitle.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    pageControl.translatesAutoresizingMaskIntoConstraints = false
    appleLoginButton.translatesAutoresizingMaskIntoConstraints = false
    
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
      appleLoginButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -20),
      appleLoginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26.5),
      appleLoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26.5),
      appleLoginButton.heightAnchor.constraint(equalToConstant: 60)
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

// MARK: - Private Helpers
extension OnboardingViewController {
  private func setupCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = view.backgroundColor
  }
  
  private func configureLoginButtonAnimation() {
    collectionView.isScrollEnabled = false
    pageControl.isHidden = true
    appleLoginButton.isHidden = false
    UIView.animate(withDuration: 1.5) {
      self.appleLoginButton.alpha = 1
    }
  }
  
  private func addTargets() {
//    kakaoLoginButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    appleLoginButton.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
  }
  
  private func setNavigationConfiguration() {
    navigationController?.navigationBar.isHidden = true
  }
  
//  private func signIn(credential: AuthCredential) -> AnyPublisher<AppleAuthResultModel, any Error> {
//    return Future { promise in
//      Auth.auth().signIn(with: credential) { result, error  in
//        if let error = error {
//          promise(.failure(error)); return
//        }
//        if let result {
//          promise(.success(AppleAuthResultModel(user: result.user))); return
//        }
//      }
//    }
//    .eraseToAnyPublisher()
//  }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
      fatalError(
        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
      )
    }
    
    let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    
    let nonce = randomBytes.map { byte in
      // Pick a random character from the set, wrapping around if needed.
      charset[Int(byte) % charset.count]
    }
    
    return String(nonce)
  }
  
  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
}

struct AppleAuthResultModel {
  let uid: String
  let email: String?
  let photoURL: String?
  
  init(user: User) {
    self.uid = user.uid
    self.email = user.email
    self.photoURL = user.photoURL?.absoluteString
  }
}

// MARK: - Actions
private extension OnboardingViewController {
  @objc func startButtonTapped() {
//    viewModel.didTapLoginButton()
  }
  
  @objc func appleButtonTapped() {

    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let nonce = randomNonceString()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)
    let authController = ASAuthorizationController(authorizationRequests: [request])
    
    authController.presentationContextProvider = self
    viewModel.didTapAppleButton(authController: authController, nonce: nonce)
//    startSignInWithAppleFlow()
  }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension OnboardingViewController: ASAuthorizationControllerPresentationContextProviding {
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    guard let window = view.window else {
      return UIWindow()
    }
    return window
  }
}
