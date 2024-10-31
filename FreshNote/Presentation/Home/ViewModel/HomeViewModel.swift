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
}

protocol HomeViewModelInput {
  func viewDidLoad()
  func numberOfItemsInSection() -> Int
  func cellForItemAt(indexPath: IndexPath) -> Product
  func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath)
  func didTapNotificationButton()
  func didTapSearchButton()
  func didTapAddButton()
}

protocol HomeViewModelOutput {
  var reloadDataPublisher: AnyPublisher<Void, Never> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
  
  // MARK: - Properties
  private let actions: HomeViewModelActions
  
  // MARK: - Output
  private var items = [Product]()
  private var reloadDataSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
  
  var reloadDataPublisher: AnyPublisher<Void, Never> { reloadDataSubject.eraseToAnyPublisher() }
  
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
    reloadDataSubject.send()
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
  
  func didTapNotificationButton() {
    actions.showNotificationPage()
  }
  
  func didTapSearchButton() {
    actions.showSearchPage()
  }
  
  func didTapAddButton() {
    print("DEBUG: 추가 버튼 tapped")
  }
}
