# MemoMemo 평과과제

|iPhone8|iPhone13ProMax|
|-|-|
|[![](http://img.youtube.com/vi/j6EiC1OHu_k/0.jpg)](https://youtu.be/j6EiC1OHu_k)|[![](http://img.youtube.com/vi/ofX3Qpj_XwI/0.jpg)](https://youtu.be/ofX3Qpj_XwI)|

# Request List
- [x] 최초 진입 팝업 뷰
    - [x] 1회만 뜸
- [x] Memo List UI
    - [x] 총 작성된 메모의 개수를 네비게이션 타이틀에 표시
    - [x] 메모가 1천개가 넘어갈 경우 1천자리 단위로 구분자
    - [x] 최신 순 정렬
    - [x] 메모 고정 (5개 제한)
    - [x] 메모 고정 5개 초과 시 얼럿 또는 토스트 
    - [x] 고정된 메모는 별도 섹션
    - [x] Ledaing Swipe
    - [x] Trailing Swipe 이미지, 삭제 경고 얼럿
    - [x] MemoCell UI
    - [x] 헤더 UI
    - [x] Date 포맷
- [x] 검색기능 구현
    - [x] 검색 결과 텍스트 컬러 변경
    - [x] 검색 결과 개수 섹션에 표시
    - [x] 검색 상태에서 드래그, 리턴 시 키보드 dismiss
    - [x] 메모 고정, 삭제 기능 검색 화면에서도 동작
    - [x] 셀 클릭 시 수정, 디테일 화면 전환 
    - [x] 검색, 추가/수정 진입에 따라 백버튼 텍스트 변경
    - [x] 검색 화면에서, 핀, 삭제
- [x] 메모 수정, 추가 UI
    - [x] 진입 시 textView becomeFirstResponder
    - [x] 키보드는 내려가지 않음
    - [x] 셀 선택 시 디테일 뷰로 진입, 터치 했을 대 수정모드로 전환
    - [x] 셀 선택시, 공유, 완료 버튼 생김
    - [x] 완료, 백버튼 액션, 제스처 시 메모 저장
    - [x] 컨텐츠가 비어있을 시 삭제 동작
    - [x] 컨텐츠 첫줄은 타이틀, 그 뒤부터는 바디로 나누어 저장
    - [x] UIActivityViewController

# Review.
## 최초 팝업 뷰 전환 생명 주기

   - 뷰 전환의 경우 viewDidLoad()에서 구현할 경우, 상위 뷰가 아직 로드 되지 않았는데 전환이 일어나면 부자연 스러움, 안될 것 까진 없지만, 그 자체로 어색하므로 viewWillAppear와 같은 다른 라이프 사이클을 활용하면 좋다.
   - viewDidLayoutSubviews의 경우 호출 조건이 bound가 변경되면 호출하게 되는데, 딱 한번 호출되는 생명 주기는 아니므로 사용에 주의 필요
   - 최초 진입 시 UserDefaults에서 최초 진입을 뜻하는 키값을 전달, 없으면 최초 진입으로 보고 있으면 두번 째 실행으로 판단
   ```Swift
   if !UserDefaults.standard.bool(forKey: "isSecondRun") {
     guard let controller = UIStoryboard(name: "Start", bundle: nil).instantiateViewController(withIdentifier: StartViewController.identifier)
      as? StartViewController else { return }
      
      controller.modalTransitionStyle = .crossDissolve
      controller.modalPresentationStyle = .overFullScreen
      
      present(controller, animated: true, completion: nil)
    }
   ```
   - okButton으로 dismiss 되어야지만 `isSecondRun` 키값이 생성되도록

## 고정된 메모는 별도 섹션
- 테이블뷰의 데이터소스를 `DiffableDataSource`를 사용
```Swift
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
```
- `isFiltering` 상태일 때는 필터링 된 내용만 보여줄 것이기 때문에 section0만 data에 추가되도록
- 아닌 경우 `pinnedMemo` 가 비어있다는 것은 고정된 메모가 없다는 것이기 때문에 section0을 일반 메모 섹션으로 사용
- `pinnedMemo`가 비어있지 않을 경우 고정된 메모가 있는 경우이므로 section0을 고정된 메모로 사용, 그리고 section1은 일반 메모 섹션으로 변경

- Section Title의 경우 `viewForHeaderInSection` 델레게이트 메소드에서 분기로 사용
```Swift
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
```

## Leading, Trailing Swipe Action
- 테이블 뷰의 경우 기본적으로 Trailing Swipe Action을 Delete로 제공하지만 Delete 문구를 휴지통으로 바꾸귀 위해 재정의
- TableView Delegate에서 `trailingSwipeActionsConfigurationForRowAt`와 `leadingSwipeActionsConfigurationForRowAt` 메소드를 이용해서 `UISwipeActionsConfigureation`를 반환할 수 있다. `UISwipeActionsConfigureation`에 대한 별도 공부가 필요해 보임
```Swift
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
```

## SearchController 
- SearchController를 별도의 클래스를 작성해서 구현하느냐, 그냥 사용하느냐
  - SearchController 별도의 클래스를 작성하지 않으면 아무래도 Filtered Array가 필요해지고 해당 분기에 대해 모두 코드가 한 컨트롤러에 들어가게 되므로 리펙토링 관점에서 클래스를 나누는 것이 더 좋아 보인다.

```Swift
let searchController = UISearchController(searchResultsController: nil)
```
- 리스트 뷰에서 UISearchCotnroller 파라메터로 뷰 컨트롤러 클래스를 별도로 전달하지 않을 경우 리스트 뷰 컨트롤러세어 모두 작성
- 위 인스턴스 생성에서 뷰 컨트롤러를 전달한뒤, 델리게이트 메소드에서 호춣해 클래스 별도 작성 해서 사용 가능
```Swift
extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchResultsVC = searchController.searchResultsController as! SearchResultsTableViewController
        guard let searchText = searchController.searchBar.text else {
            return
        }
        searchResultsVC.searchText = searchText
    }    
}
```

## 추가/수정 뷰 진입시 구분 방법론
- 본인의 경우 추가/수정 뷰(DetailView 로 명) 진입 시 수정모드 인지 추가 모드인지 구분하는 방법으로 Memo의 인스턴스를 옵셔널로 선언해 nil이면 새 메모이고, 바인딩에 성공하면 수정 모드로 구분함
- 추가 확장성을 고려했을 때 Enum으로 분기처리를 하는 것도 괜찮은 방법일 수 있음

## "추가 텍스트 없음"
- Detail View에서 타이틀만 작성하고, 본문은 작성하지 않았을 때, "추가 텍스트 없음"로 표시 해주어야 하는데 못보고 지나침
- 데이터 모델이 Title과 Body로 나뉘어져 있는데 Body가 nil 또는 empty일 때 Cell Configure에서 "추가 텍스트 없음"을 전달해서 해결해 볼 수 있음
- 다만 리턴키가 여러번 입력된 경우 '\n'문자를 내용이 있는걸로 보고 추가 텍스트 없음 문구를 띄우지 않는데 이 경우 '\n'문자를 필터링 하는 방법을 사용해 볼 수 있겠음
```Swift
    if memo.content.filter({$0 != "\n"}).isEmpty {
      contentLabel.text = "추가 텍스트 없음"
    } else {
      contentLabel.text = memo.content
    }
```

## DetailView에서 키보드가 팝업 되었을 때 스크롤해서 볼 수 있게 하기
- Notification을 이용해서 keyboardframe이 change되었을 때 tableView Cell 의 높이를 수정해서 가능하게 했다.
- 영상 찍을 당시만 해도 잘 됬던거 같은데 지금 확인 해보니, 에디트 모드로 들어갔을 때는 잘 되는데, 새 메모 추가시에는 메소드들의 실행 순서때문에 동작 하지 않는다. 해결 못하고 있음
```Swift
  func keyboardNotificationSetup() {
    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
      self.handleKeyboard(notification: notification)
    }
  }
```
- NotificationObserver 설정
```Swift
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.bounds.height - keyboardHeight
  }
```

- NofiticationObserver Remove를 빼먹어서 추가
```Swift
  func keyboardNotificationSetup() {
    var token: NSObjectProtocol?
    token = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (notification) in
      self.handleKeyboard(notification: notification)
      NotificationCenter.default.removeObserver(token!)
    }
  }
```
- 일회성 Notification을 삭제할때는 위 방법이 좋다고 함
- 셀 높이 수정
```Swift
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.bounds.height + keyboardHeight
  }
```

# ...

- [Memo 평가과제 팀 리뷰](https://gookbobhenry.notion.site/8b4ca188fac2410ba01caf623116420b)