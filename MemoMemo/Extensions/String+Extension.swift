//
//  String+Extension.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import Foundation

extension Int {
  var thousandDivideString: String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    return numberFormatter.string(from: self as NSNumber) ?? ""
  }
}


