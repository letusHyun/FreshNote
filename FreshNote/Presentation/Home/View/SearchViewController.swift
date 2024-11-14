//
//  SearchViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import UIKit
import Combine

final class SearchViewController: BaseViewController {
  // MARK: - Properties
  private let tableView: UITableView = {
    let tb = UITableView()
    tb.rowHeight = 60
    tb.register(
      RecentSearchKeywordCell.self,
      forCellReuseIdentifier: RecentSearchKeywordCell.id
    )
    return tb
  }()
  
  private let textField: PaddingTextField = {
    let tf = PaddingTextField()
    tf.layer.borderColor = UIColor(fnColor: .orange2).cgColor
    tf.layer.borderWidth = 0.8
    tf.layer.cornerRadius = 3
    let placeholderAttr = NSAttributedString(
      string: "상품명, 카테고리, 메모를 검색해주세요.",
      attributes: [
        NSAttributedString.Key.font: UIFont.pretendard(size: 12, weight: ._400),
        NSAttributedString.Key.foregroundColor: UIColor(fnColor: .placeholder)
      ]
    )
    tf.attributedPlaceholder = placeholderAttr
    return tf
  }()
  
  private let cancelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("취소", for: .normal)
    btn.titleLabel?.font = UIFont.pretendard(size: 15, weight: ._400)
    btn.setTitleColor(UIColor(fnColor: .gray), for: .normal)
    return btn
  }()
  
  private let viewModel: any SearchViewModel
  private var subscriptions: Set<AnyCancellable> = []
  
  // MARK: - LifeCycle
  init(viewModel: any SearchViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    defer { viewModel.viewDidLoad() }
    bind(to: self.viewModel)
    setupTableView()
    addTargets()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
    tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - SetupUI
  override func setupLayout() {
    let descriptionLabel = makeDescriptionLabel()
    
    view.addSubview(textField)
    view.addSubview(cancelButton)
    view.addSubview(descriptionLabel)
    view.addSubview(tableView)
    
    textField.translatesAutoresizingMaskIntoConstraints = false
    cancelButton.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
  
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
      textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      textField.heightAnchor.constraint(equalToConstant: 40)
    ] + [
      cancelButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 10),
      cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      cancelButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
      cancelButton.widthAnchor.constraint(equalToConstant: 33),
      cancelButton.heightAnchor.constraint(equalTo: textField.heightAnchor)
    ])
    
    NSLayoutConstraint.activate([
      descriptionLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15),
      descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
    ] + [
      tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}

// MARK: - Private Helpers
extension SearchViewController {
  private func makeDescriptionLabel() -> UILabel {
    let lb = UILabel()
    lb.font = UIFont.pretendard(size: 12, weight: ._400)
    lb.text = "최근 검색어"
    lb.textColor = UIColor(fnColor: .gray)
    return lb
  }
  
  private func addTargets() {
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
  }
  
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
  }
}

// MARK: - Bind
private extension SearchViewController {
  func bind(to viewModel: any SearchViewModel) {
    viewModel.reloadDataPublisher.sink { [weak self] _ in
      self?.tableView.reloadData()
    }
    .store(in: &subscriptions)
    
    viewModel.deleteRowsPublisher.sink { [weak self] indexPath in
      self?.tableView.deleteRows(at: [indexPath], with: .fade)
    }
    .store(in: &subscriptions)
  }
}

// MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
  func tableView(
    _ tableView: UITableView,
    numberOfRowsInSection section: Int
  ) -> Int {
    viewModel.numberOfRowsInSection()
  }
  
  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: RecentSearchKeywordCell.id,
      for: indexPath
    ) as? RecentSearchKeywordCell else { return UITableViewCell() }
    cell.delegate = self
    
    let keyword = viewModel.cellForRow(at: indexPath)
    cell.configure(keyword: keyword)
    
    return cell
  }
}

// MARK: - Actions
private extension SearchViewController {
  @objc func cancelButtonTapped() {
    viewModel.didTapCancelButton()
  }
}

extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.selectionStyle = .none
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // 버튼 클릭 시, 해당 키워드의 검색 결과 화면으로 이동
  }
}

// MARK: - RecentSearchKeywordCellDelegate
extension SearchViewController: RecentSearchKeywordCellDelegate {
  func didTapDeleteButton(in cell: UITableViewCell) {
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    
    viewModel.didTapKeywordDeleteButton(at: indexPath)
  }
}
