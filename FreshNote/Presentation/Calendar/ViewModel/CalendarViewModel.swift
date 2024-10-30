//
//  CalendarViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/28/24.
//

import Foundation

struct CalendarViewModelActions {
  
}

protocol CalendarViewModel { }



final class DefaultCalendarViewModel: CalendarViewModel {
  // MARK: - Properties
  private let actions: CalendarViewModelActions
  
  // MARK: - LifeCycle
  init(actions: CalendarViewModelActions) {
    self.actions = actions
  }
}
