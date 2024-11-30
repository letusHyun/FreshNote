//
//  FirebaseNetworkService.swift
//  FreshNote
//
//  Created by SeokHyun on 11/11/24.
//

import Combine
import Foundation

import FirebaseFirestore
import FirebaseStorage

enum FirebaseNetworkServiceError: Error {
  case invalidData
  case encodingError
  case dataUploadFailed
}

protocol FirebaseNetworkService {
  func getDocument<T: Decodable>(documentPath: String) -> AnyPublisher<T, any Error>
  func setDocument<T: Encodable>(documentPath: String, requestDTO: T, merge: Bool) -> AnyPublisher<Void, any Error>
  func uploadData(path: String, fileName: String, data: Data) -> AnyPublisher<URL, any Error>
  func deleteData(path: String) -> AnyPublisher<Void, any Error>
}

final class DefaultFirebaseNetworkService: FirebaseNetworkService {
  private let firestore = Firestore.firestore()
  private let storage = Storage.storage()
  
  func setDocument<T: Encodable>(
    documentPath: String,
    requestDTO: T,
    merge: Bool
  ) -> AnyPublisher<Void, any Error> {
    return Future { [weak self] promise in
      guard let dictionary = try? requestDTO.toDictionary() else {
        return promise(.failure(FirebaseNetworkServiceError.encodingError))
      }
      
      self?.firestore.document(documentPath)
        .setData(dictionary, merge: merge) { error in
          if let error = error {
            promise(.failure(error))
          }
          promise(.success(()))
        }
    }
    .eraseToAnyPublisher()
  }
  
  func getDocument<T: Decodable>(documentPath: String) -> AnyPublisher<T, any Error> {
    return Future { [weak self] promise in
      self?.firestore.document(documentPath).getDocument { (snapshot, error) in
        if let error = error {
          promise(.failure(error))
        }
        
        guard let dictionary = snapshot?.data() else { return promise(.failure(FirebaseNetworkServiceError.invalidData)) }
        
        do {
          let data = try JSONSerialization.data(withJSONObject: dictionary)
          let decodedDate = try JSONDecoder().decode(T.self, from: data)
          promise(.success(decodedDate))
        } catch {
          promise(.failure(error))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  // MARK: - Firebase Storage
  func uploadData(path: String, fileName: String, data: Data) -> AnyPublisher<URL, any Error> {
    let relativePath = "\(path)/\(fileName)"
    let storageReference = self.storage.reference().child(relativePath)
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpeg"
    
    return Future { promise in
      storageReference.putData(data, metadata: metaData) { (_, error) in
        if let error = error { return promise(.failure(error)) }
        
        storageReference.downloadURL { url, error in
          if let error = error { return promise(.failure(error)) }
          
          guard let url = url else { return promise(.failure(FirebaseNetworkServiceError.dataUploadFailed)) }
          return promise(.success(url))
        }
      }
    }
    .eraseToAnyPublisher()
  }
  
  func deleteData(path: String) -> AnyPublisher<Void, any Error> {
    return Future { [weak self] promise in
      self?.storage.reference(withPath: path).delete { error in
        if let error = error { return promise(.failure(error)) }
        promise(.success(()))
      }
    }
    .eraseToAnyPublisher()
  }
}
