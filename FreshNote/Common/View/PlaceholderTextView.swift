//
//  PlaceholderTextView.swift
//  FreshNote
//
//  Created by SeokHyun on 11/15/24.
//

import Combine
import UIKit

final class PlaceholderTextView: UITextView {
  // MARK: - Constants
  var leftPadding: CGFloat { 25 }
  
  var topPadding: CGFloat { 8 }
  
  // MARK: - Properties
  private let placeholderLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(fnColor: .gray1)
    return label
  }()
  
  var placeholder: String? {
    didSet {
      self.placeholderLabel.text = self.placeholder
      self.updatePlaceholderVisibility()
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
      self.externalDelegate = newValue
      super.delegate = self
    }
  }
  
  private let keyboardToolbar = BaseKeyboardToolbar()
  
  // MARK: - LifeCycle
  convenience init() {
    self.init(frame: .zero, textContainer: nil)
    self.setupLayout()
    self.addObserver()
    self.setupStyle()
    self.bind()
    self.setupToolbar()
  }
  
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Helpers
  private func setupToolbar() {
    self.inputAccessoryView = self.keyboardToolbar
  }
  
  private func bind() {
    self.keyboardToolbar.tapPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.endEditing(true)
      }
      .store(in: &self.subscriptions)
  }
  
  private func addObserver() {
    NotificationCenter.default
      .publisher(for: UITextView.textDidChangeNotification, object: self)
      .sink { [weak self] _ in
        self?.self.updatePlaceholderVisibility()
      }
      .store(in: &self.subscriptions)
  }
  
  private func setupLayout() {
    addSubview(self.placeholderLabel)
    
    self.placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: self.topPadding),
      self.placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.leftPadding)
    ])
  }
  
  private func updatePlaceholderVisibility() {
    self.placeholderLabel.isHidden = !text.isEmpty
  }
  
  private func setupStyle() {
    self.textContainerInset = UIEdgeInsets(
      top: self.topPadding,
      left: self.leftPadding - 3,
      bottom: .zero,
      right: self.leftPadding
    )
  }
}

// MARK: - UITextViewDelegate
extension PlaceholderTextView: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.updatePlaceholderVisibility()
    
    self.externalDelegate?.textViewDidBeginEditing?(textView)
  }
}
