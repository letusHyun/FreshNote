//
//  ProductViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 11/14/24.
//

import Combine
import UIKit

final class ProductViewController: BaseViewController, KeyboardEventable {
  // MARK: - Properties
  private let viewModel: any ProductViewModel
  
  private let backButton = NavigationBackButton()
  
  var subscriptions = Set<AnyCancellable>()
  
  private let titleTextField: DynamicTextField = {
    let tf = DynamicTextField(borderColor: UIColor(fnColor: .gray3), widthConstant: 100)
    tf.textColor = UIColor(fnColor: .gray1)
    tf.textAlignment = .center
    tf.font = UIFont.pretendard(size: 16, weight: ._500)
    tf.placeholder = "음식 이름"
    return tf
  }()
  
  private let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFit
    iv.clipsToBounds = true
    iv.layer.cornerRadius = 8
    iv.layer.borderWidth = 2
    iv.layer.borderColor = UIColor(fnColor: .orange1).cgColor
    iv.image = UIImage(systemName: "camera")?.withInsets(.init(top: 28, left: 28, bottom: 28, right: 28))
    return iv
  }()
  
  private let expirationLabel: UILabel = {
    let lb = UILabel()
    lb.text = "유통기한"
    lb.font = UIFont.pretendard(size: 12, weight: ._500)
    lb.textColor = .black
    return lb
  }()
  
  private let categoryLabel: UILabel = {
    let lb = UILabel()
    lb.text = "카테고리"
    lb.font = UIFont.pretendard(size: 12, weight: ._500)
    lb.textColor = .black
    return lb
  }()
  
  private let expirationTextField: PaddingTextField = {
    let tf = PaddingTextField()
    // TODO: - 현재 날자를 placeholder로 보여주는 알고리즘 작성하기
    tf.placeholder = "24.12.31"
    tf.layer.cornerRadius = 8
    tf.layer.borderColor = UIColor(fnColor: .gray0).cgColor
    tf.layer.borderWidth = 1
    return tf
  }()
  
  private let categoryTextField: PaddingTextField = {
    let tf = PaddingTextField()
    tf.placeholder = "카테고리 입력창"
    tf.layer.cornerRadius = 8
    tf.layer.borderColor = UIColor(fnColor: .gray0).cgColor
    tf.layer.borderWidth = 1
    return tf
  }()
  
  private let descriptionTextView: PlaceholderTextView = {
    let tv = PlaceholderTextView()
    tv.textColor = UIColor(fnColor: .gray1)
    tv.font = UIFont.pretendard(size: 16, weight: ._500)
    tv.placeholder = "메모를 입력하세요."
    tv.layer.cornerRadius = 20
    tv.layer.borderWidth = 2
    tv.layer.borderColor = UIColor(fnColor: .orange2).cgColor
    return tv
  }()
  
  private let saveButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("완료", for: .normal)
    btn.setTitleColor(UIColor(fnColor: .gray3), for: .normal)
    btn.titleLabel?.font = UIFont.pretendard(size: 20, weight: ._600)
    return btn
  }()
  
  var transformView: UIView { self.view }
  
  // TODO: - to erase
  private let dummyStackview: UIStackView = {
    let sv = UIStackView()
    _=(0...2).map {
      let lb = UILabel()
      lb.text = "\($0)"
      lb.textColor = .black
      lb.font = .systemFont(ofSize: 20)
      return lb
    }.map {
      sv.addArrangedSubview($0)
    }
    
    sv.axis = .vertical
    sv.alignment = .fill
    sv.distribution = .fillEqually
    return sv
  }()
  
  private lazy var dummyTableView: UITableView = {
    let tv = UITableView()
    tv.register(UITableViewCell.self, forCellReuseIdentifier: "DummyCell")
    tv.dataSource = self
    tv.rowHeight = UITableView.automaticDimension
    tv.estimatedRowHeight = 44
    return tv
  }()
  
  private let dummyModels: [Int] = {
    return (0...20).map { $0 }
  }()
  
  // MARK: - LifeCycle
  init(viewModel: any ProductViewModel) {
    self.viewModel = viewModel
    
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupNavigationBar()
    self.bind(to: self.viewModel)
    self.bindAction()
    self.bindKeyboard()
    navigationController?.navigationBar.backgroundColor = .white
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.tabBarController?.tabBar.isHidden = false
  }
  
  // MARK: - SetupUI
  override func setupLayout() {
    _=[self.titleTextField,
       self.imageView,
       self.expirationLabel,
       self.expirationTextField,
       self.categoryLabel,
       self.categoryTextField,
       self.descriptionTextView]
      .map {
        view.addSubview($0)
        $0.translatesAutoresizingMaskIntoConstraints = false
      }
    
    let safeArea = self.view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      self.titleTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
      self.titleTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      
      self.imageView.topAnchor.constraint(equalTo: self.titleTextField.bottomAnchor, constant: 23),
      self.imageView.widthAnchor.constraint(equalToConstant: 100),
      self.imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
      self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      
      self.expirationLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 45),
      self.expirationLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18),
      
      self.expirationTextField.topAnchor.constraint(equalTo: self.expirationLabel.bottomAnchor, constant: 10),
      self.expirationTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.5),
      self.expirationTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16.5),
      self.expirationTextField.heightAnchor.constraint(equalToConstant: 58),
      
      self.categoryLabel.topAnchor.constraint(equalTo: self.expirationTextField.bottomAnchor, constant: 10),
      self.categoryLabel.leadingAnchor.constraint(equalTo: self.expirationLabel.leadingAnchor),
      
      self.categoryTextField.topAnchor.constraint(equalTo: self.categoryLabel.bottomAnchor, constant: 10),
      self.categoryTextField.leadingAnchor.constraint(equalTo: self.expirationTextField.leadingAnchor),
      self.categoryTextField.trailingAnchor.constraint(equalTo: self.expirationTextField.trailingAnchor),
      self.categoryTextField.heightAnchor.constraint(equalToConstant: 58),
      
      self.descriptionTextView.topAnchor.constraint(equalTo: self.categoryTextField.bottomAnchor, constant: 25),
      self.descriptionTextView.leadingAnchor.constraint(equalTo: self.expirationTextField.leadingAnchor),
      self.descriptionTextView.trailingAnchor.constraint(equalTo: self.expirationTextField.trailingAnchor),
      self.descriptionTextView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -46)
    ])
  }
}

private extension ProductViewController {
  // MARK: - Bind
  func bind(to viewModel: any ProductViewModel) {
    
  }
  
  // MARK: - Actions
  func bindAction() {
    self.backButton.publisher(for: .touchUpInside)
      .sink { [weak self] _ in
        self?.viewModel.didTapBackButton()
      }
      .store(in: &self.subscriptions)
    
    self.saveButton.publisher(for: .touchUpInside)
      .sink { [weak self] _ in
//        self?.viewModel.didTapSaveButton()
        guard let self = self else { return }
        
        // TODO: - 해당 코드는 coordinator로 들어갈 예정
        let bottomSheetViewController = BottomSheetViewController()
        bottomSheetViewController.add(
          child: PhotoBottomSheetViewController(),
          container: bottomSheetViewController.bottomSheetView
        )
        bottomSheetViewController.modalPresentationStyle = .overFullScreen
        self.present(bottomSheetViewController, animated: false)
      }
      .store(in: &self.subscriptions)
  }
}

// MARK: - Private Helpers
extension ProductViewController {
  private func setupNavigationBar() {
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.saveButton)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)
  }
}

extension ProductViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dummyModels.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "DummyCell", for: indexPath) as? DummyCell else { return UITableViewCell() }
    cell.configure(text: String(dummyModels[indexPath.row]))
    return cell
  }
}
