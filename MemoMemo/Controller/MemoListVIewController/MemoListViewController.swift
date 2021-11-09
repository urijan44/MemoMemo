//
//  ViewController.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/08.
//

import UIKit
import RealmSwift

class MemoListViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var toolbar: UIToolbar!
  
  let localRealm = try! Realm()
  var filteredMemo: Results<Memo>!
  
  let searchController = UISearchController(searchResultsController: nil)
  
  var isFirstRunning = false
  
  var isSearchBarEmpty: Bool {
    searchController.searchBar.text?.isEmpty ?? true
  }
  
  var isFiltering: Bool {
    searchController.isActive && !isSearchBarEmpty
  }
  
  var dataSource: UITableViewDiffableDataSource<Int, Memo>!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableViewConfigure()
    navigationConfigure()
    searchControllerConfigure()
  
    filteredMemo = localRealm.objects(Memo.self)
    
    print(localRealm.configuration.fileURL!)
    configureDataSource()
    updateDataSource()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateDataSource()
  }
  
  func filterContentForSearchText(_ searchText: String) {
    if isSearchBarEmpty {
      filteredMemo = localRealm.objects(Memo.self).sorted(byKeyPath: "date", ascending: false)
    } else {
      filteredMemo = localRealm.objects(Memo.self).filter("title CONTAINS[c] '\(searchText)' OR content CONTAINS[c] '\(searchText)'").sorted(byKeyPath: "date", ascending: false)
    }
    updateDataSource(animatingDifferences: false)
    tableView.reloadData()
  }
  
  var pinnedMemo: Results<Memo> {
    localRealm.objects(Memo.self).filter("isPinned == true").sorted(byKeyPath: "date", ascending: false)
  }
  
  var defaultMemo: Results<Memo> {
    localRealm.objects(Memo.self).filter("isPinned == false").sorted(byKeyPath: "date", ascending: false)
  }
  
  @IBAction func addNewMemo(_ sender: UIBarButtonItem) {
    try! localRealm.write {
      localRealm.add(Memo(title: "테스트테스트\(Int.random(in: 1...10))", content: "테스트테스트"))
    }
    updateDataSource()
//    navigationItem.backButtonTitle = "메모"
//    performSegue(withIdentifier: Constans.Segues.addNewMemoSegue, sender: nil)
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
