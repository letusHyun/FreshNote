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
  
  let pop: (Product?) -> Void
  let showPhotoBottomSheet: (@escaping (Data?) -> Void) -> Void
  let showCategoryBottomSheet: (@escaping AnimateCategoryHandler,
                                @escaping PassCategoryHandler) -> Void
}

protocol ProductViewModel: ProductViewModelInput & ProductViewModelOutput { }

protocol ProductViewModelInput {
  func viewDidLoad()
  func didTapBackButton()
  func didTapSaveButton(name: String, expiration: String, imageData: Data?, category: String, memo: String?)
  func didTapImageView()
  func didTapCategoryTextField()
  func expirationTextFieldShouldEndEditing(_ text: String?)
  func didChangeExpirationTextField(_ text: String)
}

protocol ProductViewModelOutput {
  var categoryToggleAnimationPublisher: AnyPublisher<Void, Never> { get }
  var imageDataPublisher: AnyPublisher<Data?, Never> { get }
  var categoryPublisher: AnyPublisher<String, Never> { get }
  var expirationPublisher: AnyPublisher<ExpirationOutputState, Never> { get }
  var errorPublisher: AnyPublisher<Error?, Never> { get }
  var expirationTextPublisher: AnyPublisher<String, Never> { get }
  var isSelectedImage: Bool { get }
}

enum ExpirationOutputState {
  case invalidDate(text: String) // 유효성 검사 실패
  case inCompleteDate(text: String) // 완전히 기입하지 않은 상태
  case completeDate
  case writing
}

enum ProductViewModelMode {
  case create
  case edit
}

final class DefaultProductViewModel: ProductViewModel {
  private enum Constants {
    static var expirationValidTextCount: Int { 8 }
  }
  
  // MARK: - Properties
  private let actions: ProductViewModelActions
  
  private let mode: ProductViewModelMode
  
  private var subscriptions = Set<AnyCancellable>()
  
  /// 이전 text 길이를 저장해서 delete 감지할 때 사용하는 변수입니다.
  private var previousExpirationTextLength = 0
  
  var isSelectedImage: Bool = false
  
  // MARK: - Output
  var categoryToggleAnimationPublisher: AnyPublisher<Void, Never> {
    self.categoryToggleAnimationSubject.eraseToAnyPublisher()
  }
  var imageDataPublisher: AnyPublisher<Data?, Never> { self.imageDataSubject.eraseToAnyPublisher() }
  var categoryPublisher: AnyPublisher<String, Never> { self.categorySubject.eraseToAnyPublisher() }
  var expirationPublisher: AnyPublisher<ExpirationOutputState, Never> { self.expirationSubject.eraseToAnyPublisher() }
  var expirationTextPublisher: AnyPublisher<String, Never> { $expirationFormattedText.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<(any Error)?, Never> { self.$error.eraseToAnyPublisher() }
  
  private let categoryToggleAnimationSubject: PassthroughSubject<Void, Never> = .init()
  private let imageDataSubject: PassthroughSubject<Data?, Never> = .init()
  private let categorySubject: PassthroughSubject<String, Never> = .init()
  private let expirationSubject: PassthroughSubject<ExpirationOutputState, Never> = .init()
  private let saveProductUseCase: any SaveProductUseCase
  
  @Published private var expirationFormattedText = ""
  @Published private var error: (any Error)?
  
  // MARK: - LifeCycle
  init(
    saveProductUseCase: any SaveProductUseCase,
    actions: ProductViewModelActions,
    mode: ProductViewModelMode
  ) {
    self.saveProductUseCase = saveProductUseCase
    self.actions = actions
    self.mode = mode
  }
  
  deinit {
    print("DEBUG: \(Self.self) deinit")
  }
  
  // MARK: - Input
  func viewDidLoad() {
    // 모드에 따라서 vc placeholder 유무 결정 및, dataFetch
  }
  
  func didTapBackButton() {
    self.actions.pop(nil)
  }
  
  func didTapSaveButton(name: String, expiration: String, imageData: Data?, category: String, memo: String?) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yy.MM.dd"
    guard let date = dateFormatter.date(from: expiration) else { return }
    
    let requestValue = SaveProductUseCaseRequestValue(
      name: name,
      expirationDate: date,
      category: category,
      memo: memo,
      imageData: imageData,
      isPinned: false
    )
    
    self.saveProductUseCase.execute(requestValue: requestValue)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else { return }
        self?.error = error
      } receiveValue: { [weak self] product in
        self?.actions.pop(product)
      }
      .store(in: &self.subscriptions)
  }
  
  func didTapImageView() {
    self.actions.showPhotoBottomSheet({ [weak self] data in
      self?.isSelectedImage = data != nil
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
  
  func expirationTextFieldShouldEndEditing(_ text: String?) {
    guard let text = text, text.count >= Constants.expirationValidTextCount else {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy"
      let yearString = dateFormatter.string(from: Date())
      
      let exampleDate = String("ex)" + yearString.suffix(2) + ".01.01")
      self.expirationSubject.send(.inCompleteDate(text: "유통기한이 완전히 입력되지 않았습니다. " + exampleDate))
      return
    }
  }
  
  func didChangeExpirationTextField(_ text: String) {
    let isDeleting = text.count < self.previousExpirationTextLength
    
    // 삭제 시에는 포맷팅 없이 현재 text 사용
    if isDeleting {
      self.expirationFormattedText = text
      self.previousExpirationTextLength = text.count
      self.expirationSubject.send(.writing)
      return
    }
    
    // 입력된 텍스트에서 마지막 문자가 숫자인 경우에만 포맷팅 진행
    if let lastChar = text.last, lastChar.isNumber {
      let numbers = text.filter { $0.isNumber }
      var formatted = ""
      
      if numbers.count >= 2 {
        let year = String(numbers.prefix(2))
        formatted = year + "."
        
        if numbers.count >= 4 {
          let month = String(numbers.dropFirst(2).prefix(2))
          formatted += month + "."
          
          if numbers.count >= 5 { // day
            let day = String(numbers.dropFirst(4).prefix(2))
            formatted += day
          }
        } else {
          formatted += String(numbers.dropFirst(2))
        }
      } else {
        formatted = String(numbers)
      }
      
      self.expirationFormattedText = formatted
      self.previousExpirationTextLength = formatted.count
      
      if self.expirationFormattedText.count < Constants.expirationValidTextCount {
        self.expirationSubject.send(.writing)
      } else {
        self.validateDate(with: formatted)
      }
    }
  }
  
  // MARK: - Private Helpers
  private func validateDate(with dateString: String) {
    let associatedSring = "잘못된 유통기한입니다."
    
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
      self.expirationSubject.send(.invalidDate(text: associatedSring))
      return
    }
    
    // 월 검사 (1-12)
    guard (1...12).contains(month)
    else {
      self.expirationSubject.send(.invalidDate(text: associatedSring))
      return
    }
    
    // 해당 월의 마지막 날짜 계산
    var dateComponents = DateComponents()
    dateComponents.year = year
    dateComponents.month = month
    dateComponents.day = 1
    
    let calendar = Calendar.current
    guard let date = calendar.date(from: dateComponents),
          let range = calendar.range(of: .day, in: .month, for: date) else {
      self.expirationSubject.send(.invalidDate(text: associatedSring))
      return
    }
    
    // 일자 검사
    let isValid = (1...range.count).contains(day)
    if isValid {
      self.expirationSubject.send(.completeDate)
    } else {
      self.expirationSubject.send(.invalidDate(text: associatedSring))
    }
  }
}
