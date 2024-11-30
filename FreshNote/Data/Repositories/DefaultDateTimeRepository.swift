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
  private let firebaseNetworkService: any FirebaseNetworkService
  
  init(firebaseNetworkService: any FirebaseNetworkService) {
    self.firebaseNetworkService = firebaseNetworkService
  }
  
  func fetchDateTime(userID: String) -> AnyPublisher<Alarm, any Error> {
    let publisher: AnyPublisher<AlarmResponseDTO, any Error> = self.firebaseNetworkService.getDocument(
      documentPath: FirestorePath.userID(userID: userID)
    )
    
    return publisher.tryMap { $0.toDomain() }
      .eraseToAnyPublisher()
  }
  
  func saveDateTime(date: Int, hour: Int, minute: Int) -> AnyPublisher<Void, any Error> {
    guard let userID = FirebaseUserManager.shared.userID
    else { return Fail(error: FirebaseUserError.invalidUid).eraseToAnyPublisher() }
    
    let requestDTO = AlarmRequestDTO(date: date, hour: hour, minute: minute)
    return self.firebaseNetworkService.setDocument(
      documentPath: FirestorePath.userID(userID: userID),
      requestDTO: requestDTO,
      merge: true
    )
  }
}
