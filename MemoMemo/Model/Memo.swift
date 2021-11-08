//
//  Memo.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/08.
//

import Foundation

struct Memo {
  var id = UUID().uuidString
  var title: String
  var content: String
  var date = Date()
  var isPinned: Bool = false
  var image: String {
    id
  }
}
