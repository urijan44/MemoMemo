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
  func detailViewController(_ detailViewController: DetailViewController, deleteMemo memo: Memo, isEditMode: Bool)
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
  var isDetailViewMode = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let memo = memo {
      content = memo.title + memo.content
    } else {
      navigationBarConfigure()
    }
    
    keyboardNotificationSetup()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    saveMemo()
  }
}

//MARK: - DataSouce, Delegate
extension DetailViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ContentCell", for: indexPath)
    
    guard let textView = cell.viewWithTag(1000) as? UITextView else { return UITableViewCell() }
    if let memo = memo {
      textView.text = memo.title + memo.content
    }
    
    if !isDetailViewMode {
      textView.becomeFirstResponder()
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
  func textViewDidBeginEditing(_ textView: UITextView) {
    if isDetailViewMode {
      navigationBarConfigure()
      isDetailViewMode = false
      contentTableView.reloadData()
    }
  }
  func textViewDidChange(_ textView: UITextView) {
    content = textView.text
  }
}
