//
//  LoginCase.swift
//  FreshNote
//
//  Created by SeokHyun on 11/5/24.
//

import Foundation
import AuthenticationServices

struct AppleLoginConfig {
  let authController: ASAuthorizationController
}

struct KakaoLoginConfig {
  
}

enum LoginCase {
  case apple(AppleLoginConfig)
  case kakao(KakaoLoginConfig)
}
