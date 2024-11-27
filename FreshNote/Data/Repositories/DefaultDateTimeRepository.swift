//
//  DefaultDateTimeRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 10/26/24.
//

import Foundation
import Combine
import FirebaseFirestore

final class DefaultDateTimeRepository: DateTimeRepository {
  private let service: any FirestoreService
  
  init(service: any FirestoreService) {
    self.service = service
  }
  
  func fetchDateTime(userID: String) -> AnyPublisher<Alarm, any Error> {
    let publisher: AnyPublisher<AlarmDTO, any Error> = service.getDocument(
      documentPath: FirestorePath.userID(userID: userID)
    )
    
    return publisher.tryMap { $0.toDomain() }
      .eraseToAnyPublisher()
  }
  
  func saveDateTime(date: Int, hour: Int, minute: Int) -> AnyPublisher<Void, any Error> {
    guard let userID = FirebaseUserManager.shared.userID
    else { return Fail(error: FirestoreServiceError.noUser).eraseToAnyPublisher() }
    
    let requestDTO = AlarmDTO(date: date, hour: hour, minute: minute)
    return service.setDocument(
      documentPath: FirestorePath.userID(userID: userID),
      requestDTO: requestDTO,
      merge: true
    )
  }
}
