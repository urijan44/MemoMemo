//
//  Memo.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/08.
//

import UIKit
import RealmSwift

class Memo: Object {
  @Persisted(primaryKey: true) var _id: ObjectId
  @Persisted var title: String
  @Persisted var content: String
  @Persisted var date: Date
  @Persisted var isPinned: Bool
  
  convenience init(title: String, content: String) {
    self.init()
    self.title = title
    self.content = content
    self.date = Date()
    self.isPinned = false
  }
}
