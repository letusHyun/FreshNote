//
//  BaseTextField.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import UIKit

/// 텍스트 left padding을 제공해주는 객체입니다.
class BaseTextField: UITextField {
  // MARK: - LifeCycle
  init(leftPadding: CGFloat = 16) {
    super.init(frame: .zero)
    setPadding(leftPadding: leftPadding)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private Helpers
private extension BaseTextField {
  func setPadding(leftPadding: CGFloat) {
    self.leftView  = UIView(frame: CGRect(x: .zero, y: .zero, width: leftPadding, height: frame.height))
    self.leftViewMode = .always
  }
}
