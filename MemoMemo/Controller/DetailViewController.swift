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
  var keyboardSize: CGRect?
  var memo: Memo?
  var delegate: DetailViewControllerDelegate?
  var content = ""
  
  override func viewDidLoad() {
    super.viewDidLoad()

    navigationBarConfigure()
    keyboardNotificationSetup()
  }
  
  func navigationBarConfigure() {
    let activity = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil)
    let save = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(saveMemo))
    navigationItem.rightBarButtonItems = [save, activity]
  }
  
  func keyboardNotificationSetup() {
    NotificationCenter.default.addObserver(self, selector: #selector(getKeyboardHeight(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
  }
  
  @objc func getKeyboardHeight(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.keyboardSize = keyboardSize
    }
  }
  
  @objc func saveMemo() {
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
    if let memo = memo {
      textView.text = memo.content
    }
    textView.becomeFirstResponder()
    textView.delegate = self
    
    return cell
  }
}

extension DetailViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let keyboardSize = keyboardSize {
      print(keyboardSize.height)
      return UIScreen.main.bounds.height - 330
    } else {
      return UIScreen.main.bounds.height - 350
    }
    
  }
}

extension DetailViewController: UITextViewDelegate {
  func textViewDidChange(_ textView: UITextView) {
    content = textView.text
  }
}
