//
//  DateTimeRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 10/26/24.
//

import Foundation
import Combine

protocol DateTimeRepository {
  func fetchDateTime(userID: String, dDay: Int, time: String) -> AnyPublisher<AlarmDateTimeDTO, any Error>
  func saveDateTime(userID: String, dDay: Int, time: String) -> AnyPublisher<Void, any Error>
//  func updateDateTime(userID: String, dDay: Int, time: String) -> AnyPublisher<Void, Never>
}
