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
}

protocol SearchViewModelOutput {
  var reloadDataPublisher: AnyPublisher<Void, Never> { get }
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
  
  var reloadDataPublisher: AnyPublisher<Void, Never> { reloadDataSubjet.eraseToAnyPublisher() }
  
  // MARK: - LifeCycle
  init(actions: SearchViewModelActions) {
    self.actions = actions
  }
  
  // MARK: - Input
  func viewDidLoad() {
    // TODO: - network api fetch
    // mock
    _=(0...20).map {
      let keyword = RecentSearchKeyword(keyword: "\($0 + 1) 삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살삼겹살")
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
}
