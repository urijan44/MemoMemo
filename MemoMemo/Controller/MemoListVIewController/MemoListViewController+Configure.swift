//
//  MemoListViewController+Configure.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import Foundation
extension MemoListViewController {
  func tableViewConfigure() {
    tableView.delegate = self
    tableView.register(.init(nibName: MemoListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MemoListTableViewCell.identifier)
  }
  
  func navigationConfigure() {
    navigationController?.navigationBar.prefersLargeTitles = true
    let wholeMemo = localRealm.objects(Memo.self).count
    #if DEBUG
    title = "\((wholeMemo + 1000).thousandDivideString)개의 메모"
    #else
    title = "\((wholeMemo).thousandDivideString)개의 메모"
    #endif
  }
  
  func searchControllerConfigure() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "검색"
    searchController.searchBar.tintColor = .orange
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
}
