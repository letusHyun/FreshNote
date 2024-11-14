//
//  SearchViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 11/1/24.
//

import Foundation
import Combine

protocol SearchViewModel: SearchViewModelInput, SearchViewModelOutput { }

protocol SearchViewModelInput {
  func viewDidLoad()
  func numberOfRowsInSection() -> Int
  func cellForRow(at indexPath: IndexPath) -> RecentSearchKeyword
  func didTapCancelButton()
  func didTapKeywordDeleteButton(at indexPath: IndexPath)
}

protocol SearchViewModelOutput {
  var reloadDataPublisher: AnyPublisher<Void, Never> { get }
  var deleteRowsPublisher: AnyPublisher<IndexPath, Never> { get }
}

struct SearchViewModelActions {
  let pop: () -> Void
}

final class DefaultSearchViewModel: SearchViewModel {
  // MARK: - Properties
  private var recentKeywords: [RecentSearchKeyword] = []
  private let actions: SearchViewModelActions
  
  // MARK: - Output
  private let reloadDataSubjet: PassthroughSubject<Void, Never> = .init()
  private let deleteRowsSubject: PassthroughSubject<IndexPath, Never> = .init()
  
  var reloadDataPublisher: AnyPublisher<Void, Never> { reloadDataSubjet.eraseToAnyPublisher() }
  var deleteRowsPublisher: AnyPublisher<IndexPath, Never> { deleteRowsSubject.eraseToAnyPublisher() }
  
  // MARK: - LifeCycle
  init(actions: SearchViewModelActions) {
    self.actions = actions
  }

  // MARK: - Input
  func viewDidLoad() {
    // TODO: - network api fetch
    // mock
    _=(0...20).map {
      let keyword = RecentSearchKeyword(keyword: "삼겹살 \($0 + 1)")
      recentKeywords.append(keyword)
    }
    
    reloadDataSubjet.send()
  }
  
  func numberOfRowsInSection() -> Int {
    return recentKeywords.count
  }
  
  func cellForRow(at indexPath: IndexPath) -> RecentSearchKeyword {
    return recentKeywords[indexPath.row]
  }
  
  func didTapCancelButton() {
    actions.pop()
  }
  
  func didTapKeywordDeleteButton(at indexPath: IndexPath) {
    // call delete api
    
    recentKeywords.remove(at: indexPath.row)
    deleteRowsSubject.send(indexPath)
  }
}
