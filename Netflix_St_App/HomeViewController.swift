import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    
    
    var awardRecommendListViewController: RecommendListViewController!
    var hotRecommendListViewController: RecommendListViewController!
    var myRecommendListViewController: RecommendListViewController!
    
    // 홈 뷰가 불릴때 생성
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "award" {
            let destinationVC = segue.destination as? RecommendListViewController
            awardRecommendListViewController = destinationVC
            awardRecommendListViewController.viewModel.updateType(.award)
            awardRecommendListViewController.viewModel.fetchItems()
        } else if segue.identifier == "hot" {
            let destinationVC = segue.destination as? RecommendListViewController
            hotRecommendListViewController = destinationVC
            hotRecommendListViewController.viewModel.updateType(.hot)
            hotRecommendListViewController.viewModel.fetchItems()
        } else if segue.identifier == "my" {
            let destinationVC = segue.destination as? RecommendListViewController
            myRecommendListViewController = destinationVC
            myRecommendListViewController.viewModel.updateType(.my)
            myRecommendListViewController.viewModel.fetchItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        
        SearchAPI.search("interstella") { movies in
            guard let interstella = movies.first else { return }
            
            DispatchQueue.main.async {
                let url = URL(string: interstella.previewURL)!
                let item = AVPlayerItem(url: url)
                let sb = UIStoryboard(name: "Player", bundle: nil)
                
                // playerVC 생성
                let vc = sb.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
                vc.player.replaceCurrentItem(with: item) // 아이템 교체
                
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: false, completion: nil)
            }
        }
    }
}
