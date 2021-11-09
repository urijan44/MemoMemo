//
//  ViewController.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/10.
//

import UIKit

extension UIViewController {
  func commonAlert(title: String = "알림", body: String = "", okOnly: Bool = false, action: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
    let ok = UIAlertAction(title: "확인", style: .default, handler: action)
    alert.addAction(ok)
    
    if !okOnly {
      let cancel = UIAlertAction(title: "취소", style: .cancel)
      alert.addAction(cancel)
    }
    present(alert, animated: true, completion: nil)
  }
}
