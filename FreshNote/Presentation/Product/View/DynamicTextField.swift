//
//  DynamicTextField.swift
//  FreshNote
//
//  Created by SeokHyun on 11/15/24.
//

import Combine
import UIKit

final class DynamicTextField: UITextField {
  // MARK: - Properties
  private let dashLayer = CAShapeLayer()
  private var subscriptions = Set<AnyCancellable>()
  private var widthConstraint: NSLayoutConstraint?
  private var borderHeight: CGFloat { 1 }
  private let widthConstant: CGFloat
  /// textField의 width가 변경되었을 때만 dashLayer의 width를 설정하도록 하는 변수입니다.
  private var previousWidth: CGFloat = 0
  private let bezierPath = UIBezierPath()
  
  // MARK: - LifeCycle
  init(borderColor: UIColor, widthConstant: CGFloat) {
    self.widthConstant = widthConstant
    
    super.init(frame: .zero)
    
    self.setupLayout()
    self.setupStyle(borderColor: borderColor)
    self.bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    let shouldUpdateDashedBorder = self.previousWidth != bounds.width
    
    if shouldUpdateDashedBorder {
      self.previousWidth = bounds.width
      self.updateDashedBorder()
    }
  }
  
  // MARK: - Private Helpers
  private func setupLayout() {
    self.layer.addSublayer(self.dashLayer)
    
    self.translatesAutoresizingMaskIntoConstraints = false
    
    self.widthConstraint = self.widthAnchor.constraint(equalToConstant: self.widthConstant)
    self.widthConstraint?.isActive = true
  }
  
  private func setupStyle(borderColor: UIColor) {
    self.dashLayer.strokeColor = borderColor.cgColor
    self.dashLayer.frame.size.height = 1
    self.dashLayer.strokeColor = UIColor.black.cgColor
    self.dashLayer.lineWidth = 1
    self.dashLayer.fillColor = nil
    self.dashLayer.lineDashPattern = [2, 2]
  }
  
  private func bind() {
    NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
      .compactMap { ($0.object as? UITextField)?.text }
      .map { text in
        let textWidth = text.size(withAttributes: [.font: self.font!]).width
        return max(100, textWidth + 40)
      }
      .sink { [weak self] newWidth in
        self?.updateLayout(with: newWidth)
      }
      .store(in: &self.subscriptions)
  }
  
  private func updateLayout(with newWidth: CGFloat) {
    self.widthConstraint?.constant = newWidth
  }
  
  private func updateDashedBorder() {
    bezierPath.removeAllPoints()
    
    bezierPath.move(to: CGPoint(x: .zero, y: self.bounds.height - self.borderHeight))
    bezierPath.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - self.borderHeight))
    
    self.dashLayer.path = bezierPath.cgPath
  }
}
