//
//  DateTimeSettingViewController.swift
//  FreshNote
//
//  Created by SeokHyun on 10/22/24.
//

import UIKit
import FirebaseAuth

final class DateTimeSettingViewController: BaseViewController {
  struct Constants {
    static let dateSize: CGFloat = 50
  }
  
  // MARK: - Properties
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.text = "원하는 날짜와 알람 시간을 지정해주세요."
    label.textAlignment = .center
    label.textColor = UIColor(fnColor: .text3)
    label.font = .pretendard(size: 16, weight: ._400)
    return label
  }()
  
  private let dMinusLabel: UILabel = {
    let label = UILabel()
    label.text = "D - "
    label.textColor = UIColor(fnColor: .text3)
    label.font = .pretendard(size: Constants.dateSize, weight: ._400)
    return label
  }()
  
  private lazy var dateTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "01"
    textField.textColor = .black //
    textField.font = .pretendard(size: Constants.dateSize, weight: ._400)
    textField.keyboardType = .numberPad
    textField.delegate = self
    textField.setPlaceholderColor(UIColor(fnColor: .gray))
    return textField
  }()
  
  private let dateStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    return stackView
  }()
  
  private let datePicker: UIDatePicker = {
    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .time
    datePicker.preferredDatePickerStyle = .compact
//    datePicker.tintColor = .black
    return datePicker
  }()
  
  private let startButton: UIButton = {
    let button = UIButton()
    button.setTitle("시작하기", for: .normal)
    button.setTitleColor(UIColor(fnColor: .realBack), for: .normal)
    button.backgroundColor = UIColor(fnColor: .orange2)
    button.layer.cornerRadius = 8
    button.layer.masksToBounds = true
    return button
  }()
  
  private let viewModel: any DateTimeSettingViewModel
  
  // MARK: - LifeCycle
  init(viewModel: any DateTimeSettingViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @MainActor required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addTargets()
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  // MARK: - SetupUI
  override func setupLayout() {
    view.addSubview(descriptionLabel)
    view.addSubview(dateStackView)
    _=[dMinusLabel, dateTextField].map { dateStackView.addArrangedSubview($0) }
    view.addSubview(datePicker)
    view.addSubview(startButton)
    
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    dateStackView.translatesAutoresizingMaskIntoConstraints = false
    datePicker.translatesAutoresizingMaskIntoConstraints = false
    startButton.translatesAutoresizingMaskIntoConstraints = false
    
    let safeArea = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      descriptionLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 250),
      descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ] + [
      dateStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
      dateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ] + [
//      datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 150),
//      datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -150),
      datePicker.centerXAnchor.constraint(equalTo: dateStackView.centerXAnchor),
      datePicker.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 40)
    ] + [
      startButton.heightAnchor.constraint(equalToConstant: 54),
      startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 26.5),
      startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      startButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -60)
    ])
    
    dMinusLabel.widthAnchor.constraint(equalTo: dateStackView.widthAnchor, multiplier: 3/5).isActive = true
    dateTextField.widthAnchor.constraint(equalTo: dateStackView.widthAnchor, multiplier: 2/5).isActive = true
  }
}

// MARK: - UITextFieldDelegate
extension DateTimeSettingViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let text = textField.text else { return }
    
    if let first = text.first, first == "0", text.count == 2 {
      textField.text = String(text.dropFirst())
    }
  }
  
  func textField(
    _ textField: UITextField,
    shouldChangeCharactersIn range: NSRange,
    replacementString string: String
  ) -> Bool {
    let currentText = textField.text ?? ""
    let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
    
    return updatedText.count <= 2
  }
}

// MARK: - Private Helpers
extension DateTimeSettingViewController {
  private func addTargets() {
    startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
  }
}
 
// MARK: - Actions
private extension DateTimeSettingViewController {
  @objc func startButtonTapped() {
    // TODO: - textField와 날짜를 입력해야 버튼 눌리도록 설정하기
    
    let dateToInt = Int(dateTextField.text ?? "0") ?? 0
    viewModel.didTapStartButton(dateInt: dateToInt, hourMinuteDate: datePicker.date)
  }
}
