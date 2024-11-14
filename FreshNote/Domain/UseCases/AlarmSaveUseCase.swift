//
//  AlarmSaveUseCase.swift
//  FreshNote
//
//  Created by SeokHyun on 11/13/24.
//

import Combine
import Foundation

protocol AlarmSaveUseCase {
  func saveAlarm(date: Int, hour: Int, minute: Int) -> AnyPublisher<Void, any Error>
}

final class DefaultAlarmSaveUseCase: AlarmSaveUseCase {
  private let dateTimeRepository: any DateTimeRepository
  
  init(dateTimeRepository: any DateTimeRepository) {
    self.dateTimeRepository = dateTimeRepository
  }
  
  func saveAlarm(date: Int, hour: Int, minute: Int) -> AnyPublisher<Void, any Error> {
    return dateTimeRepository.saveDateTime(date: date, hour: hour, minute: minute)
  }
}
