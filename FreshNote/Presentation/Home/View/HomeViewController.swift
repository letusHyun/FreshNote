//
//  HomeViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 10/23/24.
//

import UIKit
import Combine

final class HomeViewController: BaseViewController {
  // MARK: - Properties
  private let viewModel: any HomeViewModel
  
  private let tableView: UITableView = {
    let tv = UITableView(frame: .zero)
    tv.estimatedRowHeight = 100
    tv.rowHeight = UITableView.automaticDimension
    tv.register(ProductCell.self, forCellReuseIdentifier: ProductCell.id)
    tv.separatorStyle = .none
    return tv
  }()
  
  private var subscriptions = Set<AnyCancellable>()
  
  private let searchButton: UIButton = {
    let btn = UIButton()
    let image = UIImage(systemName: "magnifyingglass")?
      .resized(to: CGSize(width: 27, height: 27))
    btn.setImage(image, for: .normal)
    return btn
  }()
  
  private let addButton: UIButton = {
    let btn = UIButton()
    let image = UIImage(systemName: "plus")?
      .resized(to: CGSize(width: 27, height: 27))
    btn.setImage(image, for: .normal)
    return btn
  }()
  
  private let notificationButton: UIButton = {
    let btn = UIButton()
    let image = UIImage(systemName: "bell")?
      .resized(to: CGSize(width: 27, height: 27))
    btn.setImage(image, for: .normal)
    return btn
  }()
  
  // MARK: - LifeCycle
  init(viewModel: any HomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.viewDidLoad()
    setupTableView()
    setNavigationBar()
    addTargets()
    bind(to: self.viewModel)
  }
  
  override func setupLayout() {
    view.addSubview(tableView)
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
    ])
  }
}

// MARK: - Private Helpers
extension HomeViewController {
  private func setupTableView() {
    tableView.dataSource = self
    tableView.delegate = self
  }
  
  private func setNavigationBar() {
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: notificationButton)
    let rightBarButtonItems = [addButton, searchButton].map { UIBarButtonItem(customView: $0) }
    navigationItem.rightBarButtonItems = rightBarButtonItems
    navigationItem.titleView = FreshNoteTitleView()
  }
  
  private func bind(to viewModel: any HomeViewModel) {
    viewModel.reloadDataPublisher.sink { [weak self] in
      self?.tableView.reloadData()
    }
    .store(in: &subscriptions)
  }
  
  private func addTargets() {
    notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
    searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
  }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfItemsInSection()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(
      withIdentifier: ProductCell.id,
      for: indexPath
    ) as? ProductCell else { return UITableViewCell() }
    
    let product = viewModel.cellForItemAt(indexPath: indexPath)
    cell.configure(product: product)
    
    return cell
  }
}

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
  func tableView(
    _ tableView: UITableView,
    trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(
      style: .destructive,
      title: "삭제"
    ) { [weak self] (action, view, completionHandler) in
      self?.viewModel.trailingSwipeActionsConfigurationForRowAt(indexPath: indexPath)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      completionHandler(true)
    }
    
    return UISwipeActionsConfiguration(actions: [deleteAction])
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.selectionStyle = .none
  }
}

// MARK: - Actions
private extension HomeViewController {
  @objc func notificationButtonTapped() {
    viewModel.didTapNotificationButton()
  }
  
  @objc func searchButtonTapped() {
    viewModel.didTapSearchButton()
  }
  
  @objc func addButtonTapped() {
    viewModel.didTapAddButton()
  }
}
