//
//  NotificationRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 11/13/24.
//

import Combine
import Foundation

protocol NotificationRepository {
  func saveFCMToken(userID: String, token: String) -> AnyPublisher<Void, any Error>
  func getFCMToken(userID: String) -> String?
}
