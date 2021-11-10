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
  var notificationToekn: NotificationToken?
  
  let searchController = UISearchController(searchResultsController: nil)
  
  var isFirstRunning = true
  
  var dataSource: MemoListDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableViewConfigure()
    navigationConfigure()
    searchControllerConfigure()
    notificationConfiture()
    
    filteredMemo = localRealm.objects(Memo.self)
    
    configureDataSource()
    updateDataSource()
    
    print(localRealm.configuration.fileURL!)
    
    if isFirstRunning {
      guard let controller = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: StartViewController.identifier)
      as? StartViewController else { return }
      
      controller.modalTransitionStyle = .crossDissolve
      controller.modalPresentationStyle = .overFullScreen
      
      present(controller, animated: true, completion: nil)
      
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateDataSource()
    updateUI()
  }
  
  func filterContentForSearchText(_ searchText: String) {
    if isSearchBarEmpty {
      filteredMemo = localRealm.objects(Memo.self).sorted(byKeyPath: "date", ascending: false)
    } else {
      filteredMemo = localRealm.objects(Memo.self).filter(
        "title CONTAINS[c] '\(searchText)' OR content CONTAINS[c] '\(searchText)'")
        .sorted(byKeyPath: "date", ascending: false)
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
  
  var isSearchBarEmpty: Bool {
    searchController.searchBar.text?.isEmpty ?? true
  }
  
  var isFiltering: Bool {
    searchController.isActive && !isSearchBarEmpty
  }
  
  func updateUI() {
    let wholeMemo = localRealm.objects(Memo.self).count
    #if DEBUG
    title = "\((wholeMemo + 1000).thousandDivideString)개의 메모"
    #else
    title = "\((wholeMemo).thousandDivideString)개의 메모"
    #endif
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
