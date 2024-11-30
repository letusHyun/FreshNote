//
//  DocumentID.swift
//  FreshNote
//
//  Created by SeokHyun on 11/28/24.
//

import Foundation

struct DocumentID {
  let didString: String
  
  init() {
    self.didString = UUID().uuidString
  }
}
