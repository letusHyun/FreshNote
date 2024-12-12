//
//  SearchViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import Combine
import Foundation

protocol SearchViewModel: SearchViewModelInput, SearchViewModelOutput { }

protocol SearchViewModelInput {
  func viewDidLoad()
  func numberOfRowsInSection() -> Int
  func cellForRow(at indexPath: IndexPath) -> ProductQuery
  func didTapCancelButton()
  func didTapKeywordDeleteButton(at indexPath: IndexPath)
}

protocol SearchViewModelOutput {
  var reloadDataPublisher: AnyPublisher<Void, Never> { get }
  var deleteRowsPublisher: AnyPublisher<IndexPath, Never> { get }
  var errorPublisher: AnyPublisher<(any Error)?, Never> { get }
}

struct SearchViewModelActions {
  let pop: () -> Void
}

final class DefaultSearchViewModel: SearchViewModel {
  // MARK: - Properties
  private var productQueries: [ProductQuery] = []
  private let actions: SearchViewModelActions
  private let recentProductQueriesUseCase: any RecentProductQueriesUseCase
  private var subscriptions = Set<AnyCancellable>()
  
  // MARK: - Output
  private let reloadDataSubjet: PassthroughSubject<Void, Never> = .init()
  private let deleteRowsSubject: PassthroughSubject<IndexPath, Never> = .init()
  @Published private var error: Error?
  
  var reloadDataPublisher: AnyPublisher<Void, Never> { self.reloadDataSubjet.eraseToAnyPublisher() }
  var deleteRowsPublisher: AnyPublisher<IndexPath, Never> { self.deleteRowsSubject.eraseToAnyPublisher() }
  var errorPublisher: AnyPublisher<(any Error)?, Never> { self.$error.eraseToAnyPublisher() }
  
  // MARK: - LifeCycle
  init(
    actions: SearchViewModelActions,
    recentProductQueriesUseCase: any RecentProductQueriesUseCase
  ) {
    self.actions = actions
    self.recentProductQueriesUseCase = recentProductQueriesUseCase
  }

  // MARK: - Input
  func viewDidLoad() {
    self.recentProductQueriesUseCase.fetchQueries()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else { return }
        self?.error = error
      } receiveValue: { [weak self] productQueries in
        // 빈 배열이면 검색 기록이 없다는 UI 보여주기
        
        // 빈 배열이 아니라면 reloadData
        for productQuery in productQueries {
          self?.productQueries.append(productQuery)
        }
        self?.reloadDataSubjet.send()
      }
      .store(in: &self.subscriptions)
  }
  
  func numberOfRowsInSection() -> Int {
    return self.productQueries.count
  }
  
  func cellForRow(at indexPath: IndexPath) -> ProductQuery {
    return self.productQueries[indexPath.row]
  }
  
  func didTapCancelButton() {
    self.actions.pop()
  }
  
  func didTapKeywordDeleteButton(at indexPath: IndexPath) {
    let productID = self.productQueries[indexPath.row].uuidString
    self.recentProductQueriesUseCase
      .deleteQuery(uuidString: productID)
      .sink { [weak self] completion in
        guard case .failure(let error) = completion else { return }
        self?.error = error
      } receiveValue: { [weak self] in
        self?.productQueries.remove(at: indexPath.row)
        self?.deleteRowsSubject.send(indexPath)
      }
      .store(in: &self.subscriptions)
  }
}
