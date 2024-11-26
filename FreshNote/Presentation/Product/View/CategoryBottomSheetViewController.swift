//
//  CategoryBottomSheetViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/23/24.
//

import Combine
import UIKit

import SnapKit

final class CategoryBottomSheetViewController: UIViewController {
  // MARK: - Properties
  private let viewModel: any CategoryBottomSheetViewModel
  
  private let categoryLabel: UILabel = {
    let lb = UILabel()
    lb.text = "카테고리"
    lb.font = .pretendard(size: 20, weight: ._700)
    lb.textColor = .black
    return lb
  }()
  
  private lazy var tableView: UITableView = {
    let tv = UITableView()
    tv.dataSource = self
    tv.delegate = self
    tv.rowHeight = 50
    tv.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.id)
    return tv
  }()
  
  // MARK: - LifeCycle
  init(viewModel: any CategoryBottomSheetViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupLayout()
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - SetupUI
  private func setupLayout() {
    self.view.addSubview(self.categoryLabel)
    self.view.addSubview(self.tableView)
    
    self.categoryLabel.snp.makeConstraints {
      $0.top.equalToSuperview().inset(35)
      $0.centerX.equalToSuperview()
    }
    
    self.tableView.snp.makeConstraints {
      $0.top.equalTo(self.categoryLabel.snp.bottom).offset(10)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().inset(self.safeAreaBottomHeight)
    }
  }
  
  // MARK: - Private Helpers
}

// MARK: - UITableViewDataSource
extension CategoryBottomSheetViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    self.viewModel.numberOfRowsInSection()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: CategoryCell.id,
      for: indexPath
    ) as? CategoryCell else { return UITableViewCell() }
    
    cell.configure(text: self.viewModel.cellForRow(at: indexPath))
    return cell
  }
}

// MARK: - UITableViewDelegate
extension CategoryBottomSheetViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.viewModel.didSelectRow(at: indexPath)
  }
}
