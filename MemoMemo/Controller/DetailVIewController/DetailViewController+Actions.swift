//
//  DetailViewController+Actions.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/12.
//

import UIKit

extension DetailViewController {
  @objc func showActivityViewController() {
    let activity: UIActivityViewController
    if let memo = memo {
      activity = UIActivityViewController(activityItems: [memo.title + memo.content], applicationActivities: [])
    } else {
      activity = UIActivityViewController(activityItems: [content], applicationActivities: [])
    }
    
    present(activity, animated: true)
  }
  
  func handleKeyboard(notification: Notification) {
    guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
      keyboardHeight = 0
      return
    }

    guard let info = notification.userInfo,
          let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    UIView.animate(withDuration: 0.1) {
      self.keyboardHeight = keyboardFrame.cgRectValue.height
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func dismissThisView() {
    navigationController?.popViewController(animated: true)
  }
    
  func saveMemo() {
    if let memo = memo {
      try! localRealm.write {
        if !content.isEmpty {
          if let titleSplitIndex = content.firstIndex(of: "\n") {
            memo.title = String(content[content.startIndex...titleSplitIndex])
            memo.content = String(content[content.index(after: titleSplitIndex)..<content.endIndex])
          } else {
            memo.title = content
            memo.content = ""
          }
          delegate?.detailViewController(self, with: memo, isEditMode: true)
        }
      }
      if content.isEmpty {
        delegate?.detailViewController(self, deleteMemo: memo, isEditMode: true)
      }
      navigationController?.popViewController(animated: true)
    } else {
      guard !content.isEmpty else { navigationController?.popViewController(animated: true); return }
      let title: String
      let body: String
      if let titleSplitIndex = content.firstIndex(of: "\n") {
        title = String(content[content.startIndex...titleSplitIndex])
        body = String(content[content.index(after: titleSplitIndex)..<content.endIndex])
      } else {
        title = content
        body = ""
      }
      let newMemo = Memo(title: title, content: body)
      delegate?.detailViewController(self, with: newMemo, isEditMode: false)
      navigationController?.popViewController(animated: true)
    }
  }
}
