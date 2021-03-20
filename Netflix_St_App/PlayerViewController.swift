import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var playerView: PlayerView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    let player = AVPlayer()
    
    // landscape 위치 설정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscapeRight
    }
    
    // 해당하는 뷰 컨트롤러가 올라온 상태
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.player = player
    }
    
    // 뷰가 보여지기 직전에 호출
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        play() // 해당 영화를 터치 하면 자동으로 영상이 재생
    }
    
    // 뷰가 보여지고 호출
    
    
    // 플레이 버튼을 눌렀을 때 이미지 변경
    @IBAction func togglePlayButton(_ sender: Any) {
        if player.isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        player.play()
        playButton.isSelected = true
    }
    
    func pause() {
        player.pause()
        playButton.isSelected = false
    }
    
    func reset() {
        pause()
        player.replaceCurrentItem(with: nil)
    }
    

    @IBAction func closeButtonTapped(_ sender: Any) {
        reset()
        dismiss(animated: false, completion: nil)
    }
}

// player가 진행중인지 아닌지 확인
extension AVPlayer {
    var isPlaying: Bool {
        guard self.currentItem != nil else {
            return false
        }
        return self.rate != 0
    }
}
