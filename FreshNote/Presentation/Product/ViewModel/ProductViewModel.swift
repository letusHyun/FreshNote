//
//  ProductViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 11/14/24.
//

import Foundation

struct ProductViewModelActions {
  let pop: () -> Void
}

protocol ProductViewModel: ProductViewModelInput & ProductViewModelOutput { }

protocol ProductViewModelInput {
  func viewDidLoad()
  func didTapBackButton()
  func didTapSaveButton()
}

protocol ProductViewModelOutput {
  
}

enum ProductViewModelMode {
  case create
  case edit
}

final class DefaultProductViewModel: ProductViewModel {
  // MARK: - Properties
  private let actions: ProductViewModelActions
  private let mode: ProductViewModelMode
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
    actions.pop()
  }
  
  func didTapSaveButton() {
    // 네트워크 save 요청 후
      // 성공 시 pop
      // 실패 시 return
  }
  
  // MARK: - Output
}
