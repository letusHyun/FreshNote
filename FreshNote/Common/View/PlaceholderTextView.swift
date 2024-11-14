//
//  PlaceholderTextView.swift
//  FreshNote
//
//  Created by SeokHyun on 11/15/24.
//

import Combine
import UIKit

final class PlaceholderTextView: UITextView {
  // MARK: - Properties
  private let placeholderLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(fnColor: .placeholder)
    return label
  }()
  
  var placeholder: String? {
    didSet {
      placeholderLabel.text = placeholder
      updatePlaceholderVisibility()
    }
  }
  
  private var subscriptions = Set<AnyCancellable>()
  
  /// ux를 위해 외부에서 delegate를 사용하도록 정의하고 내부에서는 externalDelegate로 바꿔서 사용
  /// PlaceholderTextView에서 UITextViewDelegate 메소드를 구현할 때, externalDelegate를 호출시켜주어야 합니다.
  private weak var externalDelegate: (any UITextViewDelegate)?
  
  override var delegate: (any UITextViewDelegate)? {
    get {
      super.delegate
    }
    set {
      externalDelegate = newValue
      super.delegate = self
    }
  }
  
  // MARK: - LifeCycle
  convenience init() {
    self.init(frame: .zero, textContainer: nil)
    setupLayout()
    addObserver()
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Helpers
  private func addObserver() {
    NotificationCenter.default
      .publisher(for: UITextView.textDidChangeNotification, object: self)
      .sink { [weak self] _ in
        self?.updatePlaceholderVisibility()
      }
      .store(in: &subscriptions)
  }
  
  private func setupLayout() {
    addSubview(placeholderLabel)
    
    placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25)
    ])
  }
  
  private func updatePlaceholderVisibility() {
    placeholderLabel.isHidden = !text.isEmpty
  }
}

// MARK: - UITextViewDelegate
extension PlaceholderTextView: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    updatePlaceholderVisibility()
    
    externalDelegate?.textViewDidBeginEditing?(textView)
  }
}
