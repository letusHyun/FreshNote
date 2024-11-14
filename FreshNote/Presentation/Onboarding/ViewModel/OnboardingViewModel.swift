//
//  OnboardingViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/21/24.
//

import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth

struct OnboardingViewModelActions {
  let showDateTimeSetting: () -> Void
}

protocol OnboardingViewModel: OnboardingViewModelInput, OnboardingViewModelOutput { }

protocol OnboardingViewModelInput {
  func viewDidLoad()
  func numberOfItemsInSection(sectionIndex: Int) -> Int
  func dataSourceCount() -> Int
  func cellForItemAt(indexPath: IndexPath) -> OnboardingCellInfo
  func didTapAppleButton(authController: ASAuthorizationController, nonce: String)
}

protocol OnboardingViewModelOutput {
}

final class DefaultOnboardingViewModel: NSObject {
  // MARK: - Properties
  fileprivate var currentNonce: String?
  private var subscriptions = Set<AnyCancellable>()
  
  private let dataSource: [OnboardingCellInfo] = {
    return [
      OnboardingCellInfo(
        description: "내가 입력한 유통 & 소비기한으로\n원하는 디데이 알림을 받아보세요.",
        lottieName: "firstOnboardingLottie"
      ),
      OnboardingCellInfo(
        description: "식품을  더 맛있게, 그리고 안전하게\n보관하기 위한  첫걸음",
        lottieName: "secondOnboardingLottie"
      )
    ]
  }()
  
  private let actions: OnboardingViewModelActions
  
  // MARK: - LifeCycle
  init(actions: OnboardingViewModelActions) {
    self.actions = actions
  }
}

// MARK: - Input
extension DefaultOnboardingViewModel: OnboardingViewModel {
  func didTapAppleButton(authController: ASAuthorizationController, nonce: String) {
    authController.delegate = self
    currentNonce = nonce
    authController.performRequests()
  }
  

  func cellForItemAt(indexPath: IndexPath) -> OnboardingCellInfo {
    return dataSource[indexPath.item]
  }
  
  func viewDidLoad() {
    
  }
  
  func numberOfItemsInSection(sectionIndex: Int) -> Int {
    return dataSource.count
  }
  
  func dataSourceCount() -> Int {
    return dataSource.count
  }
  // MARK: - Output
}

// MARK: - Private Helpers
extension DefaultOnboardingViewModel {
  private func signIn(credential: AuthCredential) -> AnyPublisher<AppleAuthResultModel, any Error> {
    return Future { promise in
      Auth.auth().signIn(with: credential) { result, error  in
        if let error = error {
          promise(.failure(error)); return
        }
        if let result {
          promise(.success(AppleAuthResultModel(user: result.user))); return
        }
      }
    }
    .eraseToAnyPublisher()
  }
}

extension DefaultOnboardingViewModel: ASAuthorizationControllerDelegate {
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential, including the user's full name.
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                     rawNonce: nonce,
                                                     fullName: appleIDCredential.fullName)
      // Sign in with Firebase.
      signIn(credential: credential)
        .sink { completion in
          if case .failure(let error) = completion {
            print("에러 발생: \(error)")
          }
        } receiveValue: { [weak self] model in
          print("model: \(model)")
          self?.actions.showDateTimeSetting()
        }
        .store(in: &subscriptions)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
      print("Sign in with Apple errored: \(error)")
    }
  }
}
