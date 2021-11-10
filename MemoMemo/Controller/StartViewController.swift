//
//  StartViewController.swift
//  MemoMemo
//
//  Created by hoseung Lee on 2021/11/10.
//

import UIKit

class StartViewController: UIViewController {
  
  static let identifier = "StartViewController"
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var okButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundView.layer.cornerRadius = 10
    okButton.layer.cornerRadius = 10
    
  }
  
  @IBAction func dismissStartView() {
    dismiss(animated: true, completion: nil)
  }
}
