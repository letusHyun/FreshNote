//
//  UIView+.swift
//  FreshNote
//
//  Created by SeokHyun on 11/20/24.
//

import UIKit

extension UIView {
  func publisher(for gestureRecognizer: UIGestureRecognizer) -> UIGestureRecognizer.InteractionPublisher {
    return UIGestureRecognizer.InteractionPublisher(gestureRecognizer: gestureRecognizer, view: self)
  }
}
