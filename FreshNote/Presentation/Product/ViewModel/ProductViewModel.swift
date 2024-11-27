//
//  ProductViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 11/14/24.
//

import Combine
import Foundation

struct ProductViewModelActions {
  typealias AnimateCategoryHandler = () -> Void
  typealias PassCategoryHandler = (String) -> Void
  
  let pop: () -> Void
  let showPhotoBottomSheet: (@escaping (Data?) -> Void) -> Void
  let showCategoryBottomSheet: (@escaping AnimateCategoryHandler,
                                @escaping PassCategoryHandler) -> Void
}

protocol ProductViewModel: ProductViewModelInput & ProductViewModelOutput { }

protocol ProductViewModelInput {
  func viewDidLoad()
  func didTapBackButton()
  func didTapSaveButton()
  func didTapImageView()
  func didTapCategoryTextField()
  func didTapKeyboardDoneButton(dateString: String?)
}

protocol ProductViewModelOutput {
  var categoryToggleAnimationPublisher: AnyPublisher<Void, Never> { get }
  var imageDataPublisher: AnyPublisher<Data?, Never> { get }
  var categoryPublisher: AnyPublisher<String, Never> { get }
  var dateValidationPublisher: AnyPublisher<Bool, Never> { get }
}

enum ProductViewModelMode {
  case create
  case edit
}

final class DefaultProductViewModel: ProductViewModel {
  // MARK: - Properties
  private let actions: ProductViewModelActions
  
  private let mode: ProductViewModelMode
  
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - Output
  var categoryToggleAnimationPublisher: AnyPublisher<Void, Never> {
    self.categoryToggleAnimationSubject.eraseToAnyPublisher()
  }
  var imageDataPublisher: AnyPublisher<Data?, Never> { self.imageDataSubject.eraseToAnyPublisher() }
  var categoryPublisher: AnyPublisher<String, Never> { self.categorySubject.eraseToAnyPublisher() }
  var dateValidationPublisher: AnyPublisher<Bool, Never> { self.dateValidationSubject.eraseToAnyPublisher() }
  
  private let categoryToggleAnimationSubject: PassthroughSubject<Void, Never> = .init()
  private let imageDataSubject: PassthroughSubject<Data?, Never> = .init()
  private let categorySubject: PassthroughSubject<String, Never> = .init()
  private let dateValidationSubject: PassthroughSubject<Bool, Never> = .init()
  
  // MARK: - LifeCycle
  init(actions: ProductViewModelActions, mode: ProductViewModelMode) {
    self.actions = actions
    self.mode = mode
  }
  
  // MARK: - Input
  func viewDidLoad() {
    // 모드에 따라서 vc placeholder 유무 결정 및, dataFetch
  }
  
  func didTapBackButton() {
    self.actions.pop()
  }
  
  func didTapSaveButton() {
    // 네트워크 save 요청 후
    // 성공 시 pop
    // 실패 시 return
  }
  
  func didTapImageView() {
    self.actions.showPhotoBottomSheet({ [weak self] data in
      self?.imageDataSubject.send(data)
    })
  }
  
  func didTapCategoryTextField() {
    let animateCategoryHandler: ProductViewModelActions.AnimateCategoryHandler = { [weak self] in
      self?.categoryToggleAnimationSubject.send()
    }
    let passCategoryHandler: ProductViewModelActions.PassCategoryHandler = { [weak self] category in
      self?.categorySubject.send(category)
    }
    
    self.actions.showCategoryBottomSheet(animateCategoryHandler, passCategoryHandler)
  }
  
  func didTapKeyboardDoneButton(dateString: String?) {
    guard var dateString else { return }
    self.validateDate(with: dateString)
  }
  
  // MARK: - Private Helpers
  func validateDate(with dateString: String) {
    // 1. 형식 검사 (YY.MM.DD)
    let components = dateString.components(separatedBy: ".")
    let yearStr = components[0]
    let monthStr = components[1]
    let dayStr = components[2]
    
    guard components.count == 3,
          let year = Int("20" + yearStr),
          let month = Int(monthStr),
          let day = Int(dayStr)
    else {
      self.dateValidationSubject.send(false)
      return
    }
    
    // 2. 월 검사 (1-12)
    guard (1...12).contains(month)
    else {
      self.dateValidationSubject.send(false)
      return
    }
    
    // 3. 해당 월의 마지막 날짜 계산
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = 1
    
    let calendar = Calendar.current
    guard let date = calendar.date(from: dateComponents),
          let range = calendar.range(of: .day, in: .month, for: date)
    else {
      self.dateValidationSubject.send(false)
      return
    }
    
    // 4. 일자 검사
    let isValid = (1...range.count).contains(day)
    self.dateValidationSubject.send(isValid)
  }
}
