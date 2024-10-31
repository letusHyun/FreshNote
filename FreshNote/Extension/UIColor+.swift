//
//  UIColor+.swift
//  FreshNote
//
//  Created by SeokHyun on 10/22/24.
//

import UIKit

extension UIColor {
  convenience init(hex: String, alpha: CGFloat = 1.0) {
    let hexString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    
    if hexString.hasPrefix("#") {
      scanner.currentIndex = hexString.index(after: hexString.startIndex)
    }
    
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)
  
    let r = (color & 0xff0000) >> 16
    let g = (color & 0x00ff00) >> 8
    let b = (color & 0x0000ff)
    
    self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: alpha)
  }
  
  convenience init(fnColor: FNColor, alpha: CGFloat = 1.0) {
    let hexString: String = fnColor.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    
    if hexString.hasPrefix("#") {
      scanner.currentIndex = hexString.index(after: hexString.startIndex)
    }
    
    var color: UInt64 = 0
    scanner.scanHexInt64(&color)
  
    let r = (color & 0xff0000) >> 16
    let g = (color & 0x00ff00) >> 8
    let b = (color & 0x0000ff)
    
    self.init(red: CGFloat(r) / 0xff, green: CGFloat(g) / 0xff, blue: CGFloat(b) / 0xff, alpha: alpha)
  }
}

/// Fresh Note에서 기본적으로 사용하는 color입니다.
enum FNColor: String {
  /// #333333
  case text3 = "#333333"
  case realBack = "#FFFFFF"
  /// #FFA03A
  case orange1 = "#FFA03A"
  /// #FF8A41
  case orange2 = "#FF8A41"
  /// #716D6D
  case gray = "#716D6D"
  /// #929090
  case placeholder = "#929090"
}
