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
  private let backgroundQueue: DispatchQueue
  
  init(
    firebaseNetworkService: any FirebaseNetworkService,
    backgroundQueue: DispatchQueue = DispatchQueue.global(qos: .userInitiated)
  ) {
    self.firebaseNetworkService = firebaseNetworkService
    self.backgroundQueue = backgroundQueue
  }
  
  // TODO: - userID는 매개변수로 적절하지 않음. 따라서 수정 필요함
  // repository 자체에서 FirebaseUseManager를 사용해서 userID를 만들것이기 때문
  func fetchDateTime(userID: String) -> AnyPublisher<Alarm, any Error> {
    let publisher: AnyPublisher<AlarmResponseDTO, any Error> = self.firebaseNetworkService.getDocument(
      documentPath: FirestorePath.userID(userID: userID)
    )
      .receive(on: self.backgroundQueue)
      .eraseToAnyPublisher()
    
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
    .receive(on: self.backgroundQueue)
    .eraseToAnyPublisher()
  }
}
