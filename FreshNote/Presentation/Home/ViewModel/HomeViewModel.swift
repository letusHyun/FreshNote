//
//  HomeViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import Foundation
import Combine

struct HomeViewModelActions {
  
}

protocol HomeViewModelInput {
  func viewDidLoad()
  func numberOfItemsInSection() -> Int
  func cellForItemAt(indexPath: IndexPath) -> Product
  func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath)
}

protocol HomeViewModelOutput {
  var itemsPublisher: AnyPublisher<[Product], Never> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
  // MARK: - Properties
  private let actions: HomeViewModelActions
  
  // MARK: - Output
  @Published private var items = [Product]()
  
  var itemsPublisher: AnyPublisher<[Product], Never> {
    $items.eraseToAnyPublisher()
  }
  
  // MARK: - LifeCycle
  init(actions: HomeViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - Input
  func viewDidLoad() {
    // firebase store에 접근해서 데이터 fetch
    for i in 0...20 {
      items.append(
        Product(
          name: "\(i+1)  제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목",
          expirationDate: Date(),
          category: "카테고리카테고리카테고리카테고리카테고리카테고리카테고리카테고리",
          memo: "메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모",
          imageURL: nil
        )
      )
    }
  }
  
  func numberOfItemsInSection() -> Int {
    items.count
  }
  
  func cellForItemAt(indexPath: IndexPath) -> Product {
    return items[indexPath.row]
  }
  
  func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath) {
    // call delete API by repository
    items.remove(at: indexPath.row)
  }
}
