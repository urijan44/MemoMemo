//
//  ViewController.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/08.
//

import UIKit

class MemoListViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var toolbar: UIToolbar!
  
  let searchController = UISearchController(searchResultsController: nil)
  var pinnedMemo: [Memo] = []
  var dummyMemo: [Memo] = [
    Memo(title: "메모1", content: "메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용"),
    Memo(title: "메모2", content: "메모2 내용"),
    Memo(title: "메모3", content: "메모3 내용"),
    Memo(title: "메모4", content: "메모4 내용"),
    Memo(title: "메모5", content: "메모5 내용"),
    Memo(title: "메모1", content: "메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용"),
    Memo(title: "메모1", content: "메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용"),
    Memo(title: "메모1", content: "메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용"),
    Memo(title: "메모1", content: "메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용"),
    Memo(title: "메모1", content: "메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용메모1 내용"),
  ]
  var filteredMemo: [Memo] = []
  
  var isFirstRunning = false
  
  var isSearchBarEmpty: Bool {
    searchController.searchBar.text?.isEmpty ?? true
  }
  
  var isFiltering: Bool {
    searchController.isActive && !isSearchBarEmpty
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableViewConfigure()
    navigationConfigure()
    searchControllerConfigure()
    dummyMemo[3].date.addTimeInterval(-60 * 60 * 24 * 3)
    dummyMemo[4].date.addTimeInterval(-60 * 60 * 24 * 21)
  }
  
  
  
  func filterContentForSearchText(_ searchText: String) {
    filteredMemo = dummyMemo.filter { (memo: Memo) -> Bool in
      if isSearchBarEmpty {
        return true
      } else {
        return memo.title.lowercased().contains(searchText.lowercased()) || memo.content.lowercased().contains(searchText.lowercased())
      }
    }
    tableView.reloadData()
  }
  
  @IBAction func addNewMemo(_ sender: UIBarButtonItem) {
    navigationItem.backButtonTitle = "메모"
    performSegue(withIdentifier: Constans.Segues.addNewMemoSegue, sender: nil)
  }
  
}

//MARK: - UISearchResultsUpdating

extension MemoListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

//MARK: - SearchBar
extension MemoListTableViewCell: UISearchBarDelegate {
  
}
