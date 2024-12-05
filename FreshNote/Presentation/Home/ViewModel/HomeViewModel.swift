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
  let productPublisher: AnyPublisher<Product?, Never>
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
  private let fetchProductUseCase: any FetchProductUseCase
  private let deleteProductUseCase: any DeleteProductUseCase
  
  // MARK: - Output
  private var reloadDataSubject: PassthroughSubject<Void, Never> = PassthroughSubject()
  private var deleteRowsSubject: PassthroughSubject<(IndexPath, SwipeCompletion), Never> = PassthroughSubject()

  
  var reloadDataPublisher: AnyPublisher<Void, Never> { self.reloadDataSubject.eraseToAnyPublisher() }
  var deleteRowsPublisher: AnyPublisher<(IndexPath, SwipeCompletion), Never> { self.deleteRowsSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<(any Error)?, Never> { self.$error.eraseToAnyPublisher() }
  
  @Published private var error: (any Error)?
  
  // MARK: - LifeCycle
  init(actions: HomeViewModelActions,
       fetchProductUseCase: any FetchProductUseCase,
       deleteProductUseCase: any DeleteProductUseCase
  ) {
    self.actions = actions
    self.fetchProductUseCase = fetchProductUseCase
    self.deleteProductUseCase = deleteProductUseCase
    
    self.bind()
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
  }
  
  func numberOfItemsInSection() -> Int {
    self.items.count
  }
  
  func cellForItemAt(indexPath: IndexPath) -> Product {
    self.items[indexPath.row]
  }
  
  func trailingSwipeActionsConfigurationForRowAt(indexPath: IndexPath, handler: @escaping SwipeCompletion) {
    let item = items[indexPath.row]
  
    self.deleteProductUseCase
      .execute(did: item.did, imageURL: item.imageURL)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else { return }
        self?.error = error
      } receiveValue: { _ in
        self.items.remove(at: indexPath.row)
        self.deleteRowsSubject.send((indexPath, handler))
      }
      .store(in: &self.subscriptions)
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
  
  // MARK: - Private Helpers
  private func bind() {
    self.actions.productPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] product in
        guard let product = product else { return }
        self?.items.append(product)
        self?.reloadDataSubject.send()
      }
      .store(in: &self.subscriptions)
  }
}
