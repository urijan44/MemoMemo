//
//  MemoListViewController+Configure.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import Foundation
import RealmSwift

extension MemoListViewController {
  func tableViewConfigure() {
    tableView.delegate = self
    tableView.register(.init(nibName: MemoListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MemoListTableViewCell.identifier)
    tableView.register(.init(nibName: MemoListTableHeaderView.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: MemoListTableHeaderView.identifier)
    tableView.keyboardDismissMode = .onDrag
  }
  
  func navigationConfigure() {
    navigationController?.navigationBar.prefersLargeTitles = true

  }
  
  func searchControllerConfigure() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "검색"
    searchController.searchBar.tintColor = .orange
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  func notificationConfiture() {
    notificationToekn = localRealm.objects(Memo.self).observe { [weak self] (changes: RealmCollectionChange) in
      guard let self = self else { return }
      switch changes {
        case .initial:
          self.updateUI()
        case .update(_, deletions: _, insertions: _, modifications: _):
          self.updateUI()
          self.updateDataSource()
        case .error(let error):
          print(error)
      }
    }
  }
}
