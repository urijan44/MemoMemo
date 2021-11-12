//
//  MemoListViewController+TableView.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import UIKit
import RealmSwift

//MARK: - DiffableDataSource
extension MemoListViewController {
  func configureDataSource() {
    
    dataSource = MemoListDataSource(tableView: tableView) { tableView, indexPath, memo in
      guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.identifier, for: indexPath)
              as? MemoListTableViewCell else { fatalError() }
        
      if self.isFiltering {
        cell.configure(memo: memo)

        let searchText = self.searchController.searchBar.text ?? ""
        
        let targetTitle = NSMutableAttributedString(string: memo.title)
        let targetContent = NSMutableAttributedString(string: memo.content)
                
        let titleRange = (memo.title as NSString).range(of: searchText, options: .caseInsensitive)
        let contentRange = (memo.content as NSString).range(of: searchText, options: .caseInsensitive)
        
        targetTitle.addAttribute(.foregroundColor, value: UIColor.orange, range: titleRange)
        targetContent.addAttribute(.foregroundColor, value: UIColor.orange, range: contentRange)
        
        cell.titleLabel.attributedText = targetTitle
        cell.contentLabel.attributedText = targetContent
        
      } else {
        switch indexPath.section {
        case 0 where !self.pinnedMemo.isEmpty:
          cell.configure(memo: memo)
        default:
          cell.configure(memo: memo)
        }
      }
      return cell
    }
  }
  
  func updateDataSource(animatingDifferences: Bool = true, deleteMemo: Memo? = nil) {
    var newSnapshot = NSDiffableDataSourceSnapshot<Int, Memo>()
    if isFiltering {
      newSnapshot.appendSections([0])
      newSnapshot.appendItems(filteredMemo.map{$0}, toSection: 0)
    } else {
      newSnapshot.appendSections([0])
      if !pinnedMemo.isEmpty {
        newSnapshot.appendItems(pinnedMemo.map{$0}, toSection: 0)
        
        if !defaultMemo.isEmpty {
          newSnapshot.appendSections([1])
          newSnapshot.appendItems(defaultMemo.map{$0}, toSection: 1)
        }
      } else {
        newSnapshot.appendItems(defaultMemo.map{$0}, toSection: 0)
      }
    }
    
    if let deleteMemo = deleteMemo {
      newSnapshot.deleteItems([deleteMemo])
    }
    dataSource.apply(newSnapshot, animatingDifferences: animatingDifferences)
  }

}

class MemoListDataSource: UITableViewDiffableDataSource<Int, Memo> {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }
}

//MARK: - TableView Delegete
extension MemoListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let memo: Memo
    if isFiltering {
      memo = filteredMemo[indexPath.row]
    } else {
      if indexPath.section == 0 && !pinnedMemo.isEmpty {
        memo = pinnedMemo[indexPath.row]
      } else if indexPath.section == 0 {
        memo = defaultMemo[indexPath.row]
      } else {
        memo = defaultMemo[indexPath.row]
      }
    }
    performSegue(withIdentifier: "ShowDetailSegue", sender: memo)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    66
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MemoListTableHeaderView.identifier)
            as? MemoListTableHeaderView else { return nil }
    
    let headerText: String
    if isFiltering {
      headerText = "\(filteredMemo.count)개 찾음"
      header.titleLabel.text = headerText
      return header
    } else {
      switch section {
        case 0:
          if !pinnedMemo.isEmpty {
            headerText = "고정된 메모"
            header.titleLabel.text = headerText
            return header
          } else if !defaultMemo.isEmpty {
            headerText = "메모"
            header.titleLabel.text = headerText
            return header
          } else {
            headerText = ""
            header.titleLabel.text = headerText
            return header
          }
        default:
          if !defaultMemo.isEmpty && !pinnedMemo.isEmpty {
           headerText = "메모"
           header.titleLabel.text = headerText
           return header
         } else {
           headerText = ""
           header.titleLabel.text = headerText
           return header
         }
        }
        
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    let defaultHeight: CGFloat = 55
    if isFiltering {
      return defaultHeight
    } else {
      return pinnedMemo.isEmpty ? 0 : defaultHeight
    }
  }
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let pinned = UIContextualAction(style: .normal, title: "") { [weak self] (_, _, _) in
      guard let self = self else { return }
      if self.isFiltering {
        let toUpdateMemo = self.filteredMemo[indexPath.row]
        try! self.localRealm.write {
          if toUpdateMemo.isPinned {
            toUpdateMemo.isPinned = false
          } else if self.pinnedMemo.count < 5 {
            toUpdateMemo.isPinned = true
          } else {
            commonAlert(self, body: Constans.AlertBody.pinnedLimit, okOnly: true)
          }
        }
        tableView.reloadData()
      } else {
        switch indexPath.section {
        case 0 where !self.pinnedMemo.isEmpty:
          let toUpdateMemo = self.pinnedMemo[indexPath.row]
          try! self.localRealm.write {
            toUpdateMemo.isPinned = false
          }
        default:
          if self.pinnedMemo.count < 5 {
            let toUpdateMemo = self.defaultMemo[indexPath.row]
            try! self.localRealm.write {
              toUpdateMemo.isPinned = true
            }
          } else {
            commonAlert(self, body: Constans.AlertBody.pinnedLimit, okOnly: true)
          }
        }
      }
    }
    
    if isFiltering {
      pinned.image = filteredMemo[indexPath.row]
        .isPinned
      ? pinSlashImage()
      : pinImage()
    } else {
      pinned.image = indexPath.section == 0
      && pinnedMemo.isEmpty
      ? pinImage()
      : indexPath.section == 0
      ? pinSlashImage()
      : pinImage()
    }
    pinned.image?.withTintColor(.white)
    pinned.backgroundColor = .orange
    return .init(actions: [pinned])
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    
    let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (_, _, _) in
      guard let self = self else { return }
      
      let alert = UIAlertController(title: "알림", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
      let ok = UIAlertAction(title: "삭제", style: .destructive) { _ in
        guard let toDeleteMemo = self.dataSource.itemIdentifier(for: indexPath) else { return }
        try! self.localRealm.write {
          self.updateDataSource(animatingDifferences: true, deleteMemo: toDeleteMemo)
          self.localRealm.delete(toDeleteMemo)
        }
      }
      
      let cancel = UIAlertAction(title: "취소", style: .cancel)
      
      alert.addAction(ok)
      alert.addAction(cancel)
      
      self.present(alert, animated: true, completion: nil)
    }
    delete.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
    delete.backgroundColor = .red
    
    let configuration = UISwipeActionsConfiguration(actions: [delete])
    configuration.performsFirstActionWithFullSwipe = true
    
    return configuration
  }
}
