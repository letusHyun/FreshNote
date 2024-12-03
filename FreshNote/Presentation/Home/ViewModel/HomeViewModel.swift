//
//  HomeViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import Combine
import Foundation

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
  var errorPublisher: AnyPublisher<(any Error)?, Never> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput {}

final class DefaultHomeViewModel: HomeViewModel {
  typealias SwipeCompletion = (Bool) -> Void
  
  // MARK: - Properties
  private let actions: HomeViewModelActions
  private var items = [Product]()
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - Output
  private var reloadDataSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
  private var deleteRowsSubject: PassthroughSubject<(IndexPath, SwipeCompletion), Never> = PassthroughSubject()
  private let fetchProductUseCase: any FetchProductUseCase
  
  var reloadDataPublisher: AnyPublisher<Void, Never> { self.reloadDataSubject.eraseToAnyPublisher() }
  var deleteRowsPublisher: AnyPublisher<(IndexPath, SwipeCompletion), Never> { self.deleteRowsSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<(any Error)?, Never> { self.$error.eraseToAnyPublisher() }
  
  @Published private var error: (any Error)?
  
  // MARK: - LifeCycle
  init(actions: HomeViewModelActions,
       fetchProductUseCase: any FetchProductUseCase
  ) {
    self.actions = actions
    self.fetchProductUseCase = fetchProductUseCase
  }
  
  // MARK: - Input
  func viewDidLoad() {
    // firebase store에 접근해서 데이터 fetch
    self.fetchProductUseCase.fetchProducts()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else { return }
        self?.error = error
      } receiveValue: { [weak self] products in
        for product in products {
          self?.items.append(product)
        }
        self?.reloadDataSubject.send()
      }
      .store(in: &self.subscriptions)

    
//    for i in 0...20 {
//      self.items.append(
//        Product(
//          did: DocumentID(),
//          name: "\(i+1)  제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목제목",
//          expirationDate: Date(),
//          category: "카테고리카테고리카테고리카테고리카테고리카테고리카테고리카테고리",
//          memo: "메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모메모",
//          imageData: nil,
//          isPinned: false
//        )
//      )
//    }

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
