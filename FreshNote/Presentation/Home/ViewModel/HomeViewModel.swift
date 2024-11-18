//
//  HomeViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import Foundation
import Combine

struct HomeViewModelActions {
  let showNotificationPage: () -> Void
  let showSearchPage: () -> Void
  let showProductPage: () -> Void
}

protocol HomeViewModelInput {
  func viewDidLoad()
  func numberOfItemsInSection() -> Int
  func cellForItemAt(indexPath: IndexPath) -> Product
  func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath, handler: @escaping (Bool) -> Void)
  func didTapNotificationButton()
  func didTapSearchButton()
  func didTapAddProductButton()
}

protocol HomeViewModelOutput {
  var reloadDataPublisher: AnyPublisher<Void, Never> { get }
  var deleteRowsPublisher: AnyPublisher<(IndexPath, (Bool) -> Void), Never> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
  typealias SwipeCompletion = (Bool) -> Void
  
  // MARK: - Properties
  private let actions: HomeViewModelActions
  
  // MARK: - Output
  private var items = [Product]()
  private var reloadDataSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
  private var deleteRowsSubject: PassthroughSubject<(IndexPath, SwipeCompletion), Never> = PassthroughSubject()
  
  var reloadDataPublisher: AnyPublisher<Void, Never> { reloadDataSubject.eraseToAnyPublisher() }
  var deleteRowsPublisher: AnyPublisher<(IndexPath, SwipeCompletion), Never> { deleteRowsSubject.eraseToAnyPublisher() }
  
  // MARK: - LifeCycle
  init(actions: HomeViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - Input
  func viewDidLoad() {
    // firebase store에 접근해서 데이터 fetch
    for i in 0...20 {
      self.items.append(
        Product(
          name: "\(i+1)  제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목",
          expirationDate: Date(),
          category: "카테고리카테고리카테고리카테고리카테고리카테고리카테고리카테고리",
          memo: "메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모",
          imageURL: nil
        )
      )
    }
    self.reloadDataSubject.send()
  }
  
  func numberOfItemsInSection() -> Int {
    self.items.count
  }
  
  func cellForItemAt(indexPath: IndexPath) -> Product {
    self.items[indexPath.row]
  }
  
  func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath, handler: @escaping SwipeCompletion) {
    // call delete API by repository
    self.items.remove(at: indexPath.row)
    
    self.deleteRowsSubject.send((indexPath, handler))
  }
  
  func didTapNotificationButton() {
    self.actions.showNotificationPage()
  }
  
  func didTapSearchButton() {
    self.actions.showSearchPage()
  }
  
  func didTapAddProductButton() {
    self.actions.showProductPage()
  }
}
