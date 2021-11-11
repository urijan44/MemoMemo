//
//  DetailViewController.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import UIKit
import RealmSwift

protocol DetailViewControllerDelegate: AnyObject {
  func detailViewController(_ detailViewController: DetailViewController, with memo: Memo, isEditMode: Bool)
}

class DetailViewController: UIViewController {
  
  @IBOutlet weak var contentTableView: UITableView! {
    didSet {
      contentTableView.delegate = self
      contentTableView.dataSource = self
    }
  }
  
  let localRealm = try! Realm()
  var memo: Memo?
  var delegate: DetailViewControllerDelegate?
  var content = ""
  var keyboardHeight: CGFloat = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBarConfigure()
    keyboardNotificationSetup()
  }
  
  func navigationBarConfigure() {
    let activity = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showActivityViewController))
    let save = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(saveMemo))
    navigationItem.rightBarButtonItems = [save, activity]
  }
  
  func keyboardNotificationSetup() {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
      self.handleKeyboard(notification: notification)
    }
  }
  
  @objc func showActivityViewController() {
    let activity: UIActivityViewController
    if let memo = memo {
      activity = UIActivityViewController(activityItems: [memo.content], applicationActivities: [])
    } else {
      activity = UIActivityViewController(activityItems: [content], applicationActivities: [])
    }
    
    present(activity, animated: true)
  }
  
  func handleKeyboard(notification: Notification) {
    guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
      return
    }

    guard let info = notification.userInfo,
          let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    keyboardHeight = keyboardFrame.cgRectValue.height
  }
  
  @objc func saveMemo() {
    guard !content.isEmpty else { dismiss(animated: true, completion: nil); return }
    if let memo = memo {
      try! localRealm.write {
        let title = String(content.split(separator: "\n").first ?? "")
        memo.title = title
        memo.content = content
      }
      delegate?.detailViewController(self, with: memo, isEditMode: true)
      navigationController?.popViewController(animated: true)
    } else {
      let title = String(content.split(separator: "\n").first ?? "")
      let newMemo = Memo(title: title, content: content)
      delegate?.detailViewController(self, with: newMemo, isEditMode: false)
      navigationController?.popViewController(animated: true)
    }
  }
}

extension DetailViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
    
    guard let textView = cell.viewWithTag(1000) as? UITextView else { return UITableViewCell() }
    textView.becomeFirstResponder()
    if let memo = memo {
      textView.text = memo.content
    }
    textView.delegate = self
    return cell
  }
}

extension DetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.bounds.height - keyboardHeight
  }
}

extension DetailViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    content = textView.text
  }
}
