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
}

protocol ProductViewModelOutput {
  var categoryToggleAnimationPublisher: AnyPublisher<Void, Never> { get }
  var imageDataPublisher: AnyPublisher<Data?, Never> { get }
  var categoryPublisher: AnyPublisher<String, Never> { get }
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
  
  private let categoryToggleAnimationSubject: PassthroughSubject<Void, Never> = .init()
  
  var imageDataPublisher: AnyPublisher<Data?, Never> {
    self.imageDataSubject.eraseToAnyPublisher()
  }
  
  private let imageDataSubject: PassthroughSubject<Data?, Never> = .init()
  
  var categoryPublisher: AnyPublisher<String, Never> {
    self.categorySubject.eraseToAnyPublisher()
  }
  
  private let categorySubject: PassthroughSubject<String, Never> = .init()
  
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
}
