import UIKit
import Firebase

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 해당 뷰 컨트롤러에 들어올 때 마다 서버에 요청해서 다시 테이블 뷰를 리로드
    let db = Database.database().reference().child("searchHistory")
    
    var searchTerms: [SearchTerm] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 해당 탭에 들어올 때 데이터를 불러옴
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        db.observeSingleEvent(of: .value) { snapshot in
            
            // [String [String: Any]] 타입의 딕셔너리
            guard let searchHistory = snapshot.value as? [String: Any] else { return }
            let data = try! JSONSerialization.data(withJSONObject: Array(searchHistory.values), options: [])
            
            let decoder = JSONDecoder()
            let searchTerms = try! decoder.decode([SearchTerm].self, from: data)
            
            // 먼저 검색한 순서대로 정렬
            self.searchTerms = searchTerms.sorted(by: { (term1, term2) in
                return term1.timestamp > term2.timestamp
            })
            
            self.tableView.reloadData()
            // 키 값을 제외한 밸류 값만 확인
            print("\(data)", "\(searchTerms)")
        }
    }
}

extension HistoryViewController: UITableViewDataSource {
    // 몇 개 가져올건지
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchTerms.count // searchTerm의 개수 반환
    }
    
    // 어떻게 표현 할건지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as? HistoryCell else {
            return UITableViewCell()
        }
        cell.searchTerm.text = searchTerms[indexPath.row].term
        return cell
    }
    
    
}

class HistoryCell: UITableViewCell {
    @IBOutlet weak var searchTerm: UILabel!
}

struct SearchTerm: Codable {
    let term: String
    let timestamp: TimeInterval // 시간 관련 Double 타입
}

