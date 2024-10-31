//
//  NotificationViewModel.swift
//  FreshNote
//
//  Created by SeokHyun on 10/31/24.
//

import Foundation
import Combine

protocol NotificationViewModel: NotificaionViewModelInput, NotificationViewModelOutput { }

protocol NotificaionViewModelInput {
  func viewDidLoad()
  func numberOfRowsInSection() -> Int
  func cellForRow(at indexPath: IndexPath) -> Notification
  func didSelectRow(at indexPath: IndexPath)
}

protocol NotificationViewModelOutput {
  var reloadDataPublisher: AnyPublisher<Void, Never> { get }
  var reloadRowPublisher: AnyPublisher<IndexPath, Never> { get }
}

final class DefaultNotificationViewModel: NotificationViewModel {
  // MARK: - Properties
  private var notifications: [Notification] = []
  
  // MARK: - Output
  private let reloadDataSubject = PassthroughSubject<Void, Never>()
  private let reloadRowSubject = PassthroughSubject<IndexPath, Never>()
  
  var reloadDataPublisher: AnyPublisher<Void, Never> {
    reloadDataSubject.eraseToAnyPublisher()
  }
  var reloadRowPublisher: AnyPublisher<IndexPath, Never> {
    reloadRowSubject.eraseToAnyPublisher()
  }
  
  // MARK: - LifeCycle
  
  // MARK: - Input
  func viewDidLoad() {
    // fetch api
    
    // mock
    for i in 0..<20 {
      let isViewed: Bool
      if i % 2 == 0 {
        isViewed = false
        notifications.append(Notification(productName: "제품\(i+1)", dDay: i+1, isViewed: isViewed))
      } else {
        isViewed = true
        notifications.append(Notification(productName: "제품\(i+1)", dDay: i+1, isViewed: isViewed))
      }
    }
    reloadDataSubject.send()
  }
  
  func numberOfRowsInSection() -> Int {
    return notifications.count
  }
  
  func cellForRow(at indexPath: IndexPath) -> Notification {
    return notifications[indexPath.row]
  }
  
  func didSelectRow(at indexPath: IndexPath) {
    guard !notifications[indexPath.row].isViewed else { return }
    // fetch api
        // 성공 시, 서버는 저장만 함
    
    // 성공 시
    notifications[indexPath.row].isViewed.toggle()
    reloadDataSubject.send()
  }
}
