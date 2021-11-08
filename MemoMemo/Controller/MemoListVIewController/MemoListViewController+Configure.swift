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
    tableView.dataSource = self
    tableView.register(.init(nibName: MemoListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MemoListTableViewCell.identifier)
  }
  
  func navigationConfigure() {
    navigationController?.navigationBar.prefersLargeTitles = true
    title = "\((dummyMemo.count + 1000).thousandDivideString)개의 메모"
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
