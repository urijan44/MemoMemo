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
  
  var dataSource: MemoListDataSource!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !UserDefaults.standard.bool(forKey: "isSecondRun") {
      guard let controller = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: StartViewController.identifier)
      as? StartViewController else { return }
      
      controller.modalTransitionStyle = .crossDissolve
      controller.modalPresentationStyle = .overFullScreen
      
      present(controller, animated: true, completion: nil)
    }

    tableViewConfigure()
    navigationConfigure()
    searchControllerConfigure()
    notificationConfiture()
    
    filteredMemo = localRealm.objects(Memo.self)
    
    configureDataSource()
    updateDataSource()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateDataSource()
    updateUI()
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
  
  func updateUI() {
    let wholeMemo = localRealm.objects(Memo.self).count
    title = "\((wholeMemo).thousandDivideString)개의 메모"
  }
  
  func pinImage() -> UIImage? {
    UIImage(systemName: "pin.fill")
  }

  func pinSlashImage() -> UIImage? {
    UIImage(systemName: "pin.slash.fill")
  }

  @IBAction func addNewMemo(_ sender: UIBarButtonItem) {
    navigationItem.backButtonTitle = "메모"
    performSegue(withIdentifier: Constans.Segues.addNewMemoSegue, sender: nil)
  }
  
  
  //MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    navigationItem.backButtonTitle = "메모"
    if segue.identifier == "AddNewMemoSegue" {
      guard let controller = segue.destination as? DetailViewController else { return }
      controller.delegate = self
    } else if segue.identifier == "ShowDetailSegue" {
      if isFiltering {
        navigationItem.backButtonTitle = "검색"
      }
      guard let controller = segue.destination as? DetailViewController else { return }
      controller.delegate = self
      controller.memo = sender as? Memo
      controller.isDetailViewMode = true
    }
  }
}

//MARK: - UISearchResultsUpdating
extension MemoListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}

//MARK: - Delegates
extension MemoListViewController: DetailViewControllerDelegate {
  func detailViewController(_ detailViewController: DetailViewController, with memo: Memo, isEditMode: Bool) {
    if !isEditMode {
      try! localRealm.write {
        localRealm.add(memo)
      }
    } 
  }
  
  func detailViewController(_ detailViewController: DetailViewController, deleteMemo memo: Memo, isEditMode: Bool) {
    updateDataSource(animatingDifferences: true, deleteMemo: memo)
    try! localRealm.write {
      localRealm.delete(memo)
    }
  }
}
