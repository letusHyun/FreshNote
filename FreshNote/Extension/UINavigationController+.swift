//
//  UINavigationController+.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import UIKit

extension UINavigationController {
//  convenience init(barStyle: FNNavigationBarStyle) {
//    self.init()
//    
//    switch barStyle {
//    case .default:
//      let naviBar = navigationBar
//      naviBar.setBackgroundImage(UIImage(), for: .default)
//      naviBar.shadowImage = UIImage()
//      naviBar.isTranslucent = true
//      naviBar.backgroundColor = .clear
//    case .else:
//      break
//    }
//  }
  
  func setupBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    appearance.backgroundColor = UIColor(fnColor: .realBack)
  }
}
