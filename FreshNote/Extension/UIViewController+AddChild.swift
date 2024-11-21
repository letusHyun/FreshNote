//
//  UIViewController+AddChild.swift
//  FreshNote
//
//  Created by SeokHyun on 11/22/24.
//

import SnapKit
import UIKit

extension UIViewController {
  /// parentVC에서 add 호출
  func add(child: UIViewController, container: UIView) {
    self.addChild(child)
    container.addSubview(child.view)
    
    child.view.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    child.didMove(toParent: self)
  }
  
  /// childVC에서 remove 호출
  func remove() {
    guard parent != nil else { return }
    
    self.willMove(toParent: nil)
    self.view.removeFromSuperview()
    self.removeFromParent()
  }
}
