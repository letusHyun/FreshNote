//
//  DefaultDateTimeRepository.swift
//  FreshNote
//
//  Created by SeokHyun on 10/26/24.
//

import Foundation
import Combine
import FirebaseFirestore

final class DefaultDateTimeRepository {
  // MARK: - Dependencies
  private let db: Firestore
  
  // MARK: - LifeCycle
  init(db: Firestore = Firestore.firestore()) {
    self.db = db
  }
}

// MARK: - DateTimeRepository
extension DefaultDateTimeRepository: DateTimeRepository {
  func fetchDateTime(userID: String, dDay: Int, time: String) -> AnyPublisher<AlarmDateTimeDTO, any Error> {
    let userIDRef = FirestoreDocumentPath.user(userID: userID).reference(db: db)
    
    return Future<AlarmDateTimeDTO, any Error> { promise in
      userIDRef.getDocument { document, error in
        if let error = error {
          promise(.failure(error))
        }
        
        if let document = document, document.exists {
          do {
            let alarmData = try document.data(as: AlarmDateTimeDTO.self)
            promise(.success(alarmData))
          } catch {
            promise(.failure(error))
          }
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  func saveDateTime(userID: String, dDay: Int, time: String) -> AnyPublisher<Void, any Error> {
    let userIDRef = FirestoreDocumentPath.user(userID: userID).reference(db: db)
    let alarmDateTimeDTO = AlarmDateTimeDTO(dDay: dDay, time: time)
    
    return Future { promise in
      do {
        try userIDRef.setData(from: alarmDateTimeDTO, merge: true) { error in
          if let error = error {
            promise(.failure(error)) // firestore의 error
          }
          promise(.success(()))
        }
      } catch {
        promise(.failure(error)) // 서버 연결 실패
      }
    }
    .eraseToAnyPublisher()
  }
  
//  func updateDateTime(userID: String, dDay: Int, time: String) -> AnyPublisher<Void, Never> {
//    return Just(_).eraseToAnyPublisher()
//  }
}
