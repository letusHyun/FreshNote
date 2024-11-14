//
//  RecentSearchKeywordCell.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import UIKit

protocol RecentSearchKeywordCellDelegate: AnyObject {
  func didTapDeleteButton(in cell: UITableViewCell)
}

final class RecentSearchKeywordCell: UITableViewCell {
  // MARK: - Properties
  static var id: String {
    return String(describing: Self.self)
  }
  
  private let keywordLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.pretendard(size: 12, weight: ._400)
    label.textColor = .black
    return label
  }()
  
  private let deleteButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(systemName: "xmark"), for: .normal)
    button.tintColor = .black
    return button
  }()
  
  weak var delegate: RecentSearchKeywordCellDelegate?
  
  // MARK: - LifeCycle
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupLayout()
    setupStyle()
    addTargets()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    keywordLabel.text = nil
  }
}

// MARK: - Helpers
extension RecentSearchKeywordCell {
  func configure(keyword: RecentSearchKeyword) {
    keywordLabel.text = keyword.keyword
  }
}

// MARK: - Private Helpers
extension RecentSearchKeywordCell {
  private func addTargets() {
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
  }
  
  private func setupLayout() {
    contentView.addSubview(keywordLabel)
    contentView.addSubview(deleteButton)
    
    keywordLabel.translatesAutoresizingMaskIntoConstraints = false
    deleteButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      keywordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      keywordLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      keywordLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
      keywordLabel.trailingAnchor.constraint(lessThanOrEqualTo: deleteButton.leadingAnchor, constant: -30)
    ] + [
      deleteButton.widthAnchor.constraint(equalToConstant: 20),
      deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor),
      deleteButton.centerYAnchor.constraint(equalTo: keywordLabel.centerYAnchor),
      deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
    ])
    
    deleteButton.setContentCompressionResistancePriority(.required, for: .horizontal)
  }
  
  private func setupStyle() {
    
  }
}

// MARK: - Actions
private extension RecentSearchKeywordCell {
  @objc func deleteButtonTapped() {
    delegate?.didTapDeleteButton(in: self)
  }
}
