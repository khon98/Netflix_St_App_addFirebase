import UIKit
import Kingfisher
import AVFoundation

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    var movies: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SearchViewController: UICollectionViewDataSource {
    // 몇개의 아이템이 넘어오는지
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count // movie 개수에 따라 넘겨줌
    }
    
    // 어떻게 표현할건지
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as? ResultCell else {
            return UICollectionViewCell()
        }
        // urlpath를 image로 변환
        let movie = movies[indexPath.item]
        let url = URL(string: movie.thumbnailPath)!
        cell.movieThumbnail.kf.setImage(with: url)
        
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // playerVC에 movie 전달
        let movie = movies[indexPath.row]
        let url = URL(string: movie.previewURL)!
        let item = AVPlayerItem(url: url)
        
        let sb = UIStoryboard(name: "Player", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "PlayerViewController") as! PlayerViewController
        vc.modalPresentationStyle = .fullScreen // 영상 재생시 전체 화면으로 나옴
        
        vc.player.replaceCurrentItem(with: item)
        present(vc, animated: false, completion: nil)
    }
}

// collectionview 사이즈 지정
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin: CGFloat = 8
        let itemspacing: CGFloat = 10
        
        let width = (collectionView.bounds.width - margin * 2 - itemspacing * 2) / 3
        let height = width * 10/7
        
        return CGSize(width: width, height: height)
    }
}

class ResultCell: UICollectionViewCell {
    @IBOutlet weak var movieThumbnail: UIImageView!
}

extension SearchViewController: UISearchBarDelegate {
    
    // 검색 완료 후 키보드 내려가게 하기
    private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    // search 버튼을 눌렀을 때 뷰 컨트롤러 한테 알려주는 메서드
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
        // 검색 완료 후 키보드 내려가게 하기
        dismissKeyboard()

        // 검색어가 있는지 확인
        // 검색어가 없으면 그대로 return
        guard let searchTerm = searchBar.text, searchTerm.isEmpty == false else { return }
        
        // 네트워킹을 통한 검색
        // 서치텀을 가지고 네트워킹을 통해 영화 검색
        SearchAPI.search(searchTerm) { movies in
            // collectionView로 표현
            print("검색에 대한 결과 값: \(movies.count), 제목: \(movies.first?.title)")
            DispatchQueue.main.async {
                self.movies = movies
                self.resultCollectionView.reloadData()
            }
            
        }
        
        print("검색어: \(searchTerm)")
    }
}

// 검색 API
// @escaping - completion 안에 있는 코드 블럭이 메서드 밖에서 실행될수도 있다
class SearchAPI {
    static func search(_ term: String, completion: @escaping ([Movie]) -> Void) {
        let session = URLSession(configuration: .default)
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?")!
        let mediaQuery = URLQueryItem(name: "media", value: "movie")
        let entityQuery = URLQueryItem(name: "entity", value: "movie")
        let termQuery = URLQueryItem(name: "term", value: term)
        urlComponents.queryItems?.append(mediaQuery)
        urlComponents.queryItems?.append(entityQuery)
        urlComponents.queryItems?.append(termQuery)
        
        let requestURL = urlComponents.url!
        
        let dataTask = session.dataTask(with: requestURL) { data, respones, error in
            let successRange = 200..<300
            
            // 에러가 없는지 확인, 없으면 다음 코드로 이동
            guard error == nil, let statusCode = (respones as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else {
                completion([])
                return
            }
            
            guard let resultData = data else {
                completion([])
                return
            }
            
            let movies = SearchAPI.parseMovie(resultData)
            completion(movies)
        }
        dataTask.resume() // 네트워킹 작업 시작
    }
    
    // data를 넣어주면 [Movie]에 대한걸로 파싱 / 파싱에 대한 메서드
    static func parseMovie(_ data: Data) -> [Movie] {
        let decoder = JSONDecoder() // decorder 생성
        
        // 파싱
        do {
            let response = try decoder.decode(Respones.self, from: data)
            let movies = response.movies
            return movies
        } catch let error {
            print("파싱 에러: \(error.localizedDescription)")
            return [] // 파싱 실패로 인한 빈 값 리턴
        }
    }
}

struct Respones: Codable {
    let resultCount: Int
    let movies: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case movies = "results" // results에 해당하는 값들을 movies로 랩핑함
    }
}

// 글자 하나만 달라도 파싱이 안될수도 있음
struct Movie: Codable {
    let title: String
    let director: String
    let thumbnailPath: String
    let previewURL: String
    
    enum CodingKeys: String, CodingKey {
        case title = "trackName"
        case director = "artistName"
        case thumbnailPath = "artworkUrl100"
        case previewURL = "previewUrl"
    }
}
