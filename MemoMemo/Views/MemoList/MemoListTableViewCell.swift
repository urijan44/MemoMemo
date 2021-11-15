//
//  MemoListTableViewCell.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/08.
//

import UIKit

class MemoListTableViewCell: UITableViewCell {
  
  static let identifier = "MemoListTableViewCell"
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var contentImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  
  func configure(memo: Memo) {
    titleLabel.text = memo.title
    dateLabel.text = memo.date.customDateString
    
    
    if memo.content.filter({$0 != "\n"}).isEmpty {
      contentLabel.text = "추가 텍스트 없음"
    } else {
      contentLabel.text = memo.content
    }
    
    let image = UIImage(named: "1")
    if image == nil {
      contentImage.frame = .zero
      layoutIfNeeded()
    }
  }
  
  
  
}
