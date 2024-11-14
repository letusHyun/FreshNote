//
//  UITextField+.swift
//  FreshNote
//
//  Created by SeokHyun on 11/5/24.
//

import UIKit

extension UITextField {
  /// textField의 placeholder Color를 변경해줍니다.
  func setPlaceholderColor(_ placeholderColor: UIColor) {
    attributedPlaceholder = NSAttributedString(
      string: placeholder ?? "",
      attributes: [
        .foregroundColor: placeholderColor,
        .font: font
      ].compactMapValues { $0 }
    )
  }
}
