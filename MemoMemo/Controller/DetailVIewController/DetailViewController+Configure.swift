//
//  DetilViewController+Configure.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/12.
//

import UIKit

extension DetailViewController {
  func navigationBarConfigure() {
    let activity = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActivityViewController))
    let save = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissThisView))
    navigationItem.rightBarButtonItems = [save, activity]
  }
  
  func keyboardNotificationSetup() {
    var token: NSObjectProtocol?
    token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
      self.handleKeyboard(notification: notification)
      NotificationCenter.default.removeObserver(token!)
    }
  }
}
