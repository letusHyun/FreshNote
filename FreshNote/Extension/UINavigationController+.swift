//
//  UINavigationController+.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import UIKit

extension UINavigationController {
  /// 내비게이션 바의 style을 지정해주는 생성자입니다.
  convenience init(barStyle: FNNavigationBarStyle) {
    self.init()
    
    switch barStyle {
    case .default:
      let naviBar = navigationBar
      naviBar.setBackgroundImage(UIImage(), for: .default)
      naviBar.shadowImage = UIImage()
      naviBar.isTranslucent = true
      naviBar.backgroundColor = .clear
    case .else:
      break
    }
  }
}

enum FNNavigationBarStyle {
  /// 기본적으로 viewController의 backgroundColor를 사용하고 스크롤 시, 내비게이션바의 반투명도를 제거합니다.
  case `default`
  case `else`
}
