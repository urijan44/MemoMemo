//
//  MemoListViewController+TableView.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/09.
//

import UIKit

//MARK: - TableView DataSource

extension MemoListViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if isFiltering {
      return 1
    } else {
      return pinnedMemo.isEmpty ? 1 : 2
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if isFiltering {
      return filteredMemo.count
    } else {
      switch section {
      case 0:
        return pinnedMemo.isEmpty ? dummyMemo.count : pinnedMemo.count
      default:
        return dummyMemo.count
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.identifier, for: indexPath)
            as? MemoListTableViewCell else { fatalError() }
    
    if isFiltering {
      let memo = filteredMemo[indexPath.row]
      cell.configure(memo: memo)
      
      let searchText = searchController.searchBar.text ?? ""
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
      case 0:
        if pinnedMemo.isEmpty {
          let memo = dummyMemo[indexPath.row]
          cell.configure(memo: memo)
        } else {
          let memo = pinnedMemo[indexPath.row]
          cell.configure(memo: memo)
        }
      default:
        let memo = dummyMemo[indexPath.row]
        cell.configure(memo: memo)
      }
    }
    
    
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
//    dummyMemo.remove(at: indexPath.row)
//    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}


//MARK: - TableView Delegete
extension MemoListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    66
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if isFiltering {
      return "\(filteredMemo.count.thousandDivideString)개 찾음"
    } else {
      switch section {
      case 0:
        return pinnedMemo.isEmpty ? "메모" : "고정된 메모"
      default:
        return "메모"
      }
    }
    
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if isFiltering {
      return 44
    } else {
      return pinnedMemo.isEmpty ? 0 : 44
    }
  }
  
  func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let pinned = UIContextualAction(style: .normal, title: "") { [weak self] (_, _, success: @escaping (Bool) -> Void) in
      guard let self = self else { return }
      
      switch indexPath.section {
      case 0:
        if self.pinnedMemo.isEmpty {
          self.pinnedMemo.append(self.dummyMemo[indexPath.row])
          self.dummyMemo.remove(at: indexPath.row)
        } else {
          self.dummyMemo.append(self.pinnedMemo[indexPath.row])
          self.pinnedMemo.remove(at: indexPath.row)
        }
      default:
        self.pinnedMemo.append(self.dummyMemo[indexPath.row])
        self.dummyMemo.remove(at: indexPath.row)
      }
      tableView.reloadData()
      success(true)
    }
    pinned.image = indexPath.section == 0 && pinnedMemo.isEmpty ? UIImage(systemName: "pin.fill") : indexPath.section == 0 ? UIImage(systemName: "pin.slash.fill") : UIImage(systemName: "pin.fill")
    pinned.image?.withTintColor(.white)
    pinned.backgroundColor = .orange
    return .init(actions: [pinned])
  }
  
  func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: "") { [weak self] (action, view, handler) in
      guard let self = self else { return }
      
      let alert = UIAlertController(title: "알림", message: "정말 삭제하시겠습니까?", preferredStyle: .alert)
      let ok = UIAlertAction(title: "삭제", style: .destructive) { _ in
        switch indexPath.section {
        case 0:
          if self.pinnedMemo.isEmpty {
            self.dummyMemo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
          } else {
            self.pinnedMemo.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
          }
        default:
          self.dummyMemo.remove(at: indexPath.row)
          tableView.deleteRows(at: [indexPath], with: .automatic)
        }
      }
      
      let cancel = UIAlertAction(title: "취소", style: .cancel)
      
      alert.addAction(ok)
      alert.addAction(cancel)
      
      self.present(alert, animated: true, completion: nil)
    }
    delete.image = UIImage(systemName: "trash.fill")?.withTintColor(.white)
    delete.backgroundColor = .red

    return .init(actions: [delete])
  }
}
