//
//  UINavigationController+.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import UIKit

extension UINavigationController {
  func setupBarAppearance() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    appearance.backgroundColor = UIColor(fnColor: .realBack)
  }
}
