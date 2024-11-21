//
//  DummyCell.swift
//  FreshNote
//
//  Created by SeokHyun on 11/20/24.
//

import UIKit

final class DummyCell: UITableViewCell {
  private let dummyLabel: UILabel = {
    let label = UILabel()
    label.text = "Dummy Cell"
    label.font = .systemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    contentView.addSubview(dummyLabel)
    dummyLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      dummyLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
      dummyLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20)
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configure(text: String) {
    dummyLabel.text = text
  }
}
