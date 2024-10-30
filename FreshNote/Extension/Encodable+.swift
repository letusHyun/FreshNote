//
//  Encodable+.swift
//  FreshNote
//
//  Created by SeokHyun on 10/24/24.
//

import Foundation

extension Encodable {
  var asDictionary: [String: Any]? {
    guard let object = try? JSONEncoder().encode(self),
          let dictinoary = try? JSONSerialization.jsonObject(with: object, options: []) as? [String: Any] else { return nil }
    return dictinoary
  }
}
