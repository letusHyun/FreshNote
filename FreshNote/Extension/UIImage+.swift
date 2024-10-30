//
//  UIImage+.swift
//  FreshNote
//
//  Created by SeokHyun on 10/31/24.
//

import UIKit

extension UIImage {
  /// 이미지에 inset을 적용해서 반환합니다.
  func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
    let width: CGFloat = self.size.width + insets.left + insets.right
    let height: CGFloat = self.size.height + insets.top + insets.bottom
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
    
    return renderer.image { _ in
      let origin = CGPoint(x: insets.left, y: insets.top)
      self.draw(at: origin)
    }
  }
}
