import UIKit
import Combine
import MBProgressHUD

class SearchTableViewController: UITableViewController, UIAnimatable {
    
    private enum Mode {
        case onboarding
        case search
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        
        ///Properties for Search Controller
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name or symbol"
        sc.searchBar.autocapitalizationType = .allCharacters
        
        return sc
    }()
    
    private let apiService = APIService() /// Publisher (Combine)
    private var subscribers = Set<AnyCancellable>() /// Subscriber (Combine)
    private var searchResults: SearchResults?
    
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery = String() ///Observe variables whenever it changes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        observeForm()
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func observeForm() {
        
        ///debounce used as a response time whenever the search result comes up (split seconds)
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                ///Showing animation when the User wait for 750 ms for the Search Results
                showLoadingAnimation()
                
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { (completion) in
                    ///Showing animation when the User wait for 750 ms for the Search Results
                    hideLoadingAnimation()
                    
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        break
                    }
                    
                } receiveValue: { (searchResults) in
                        self.searchResults = searchResults
                        self.tableView.reloadData()
                    }.store(in: &subscribers)
            }.store(in: &subscribers)
        
        $mode.sink { [unowned self] (mode) in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SearchTableViewCell
        
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult)
        }
        
        return cell
    }
    
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    
    ///Function for searching the result whenever user tapping letters on the keyboard
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, 
                !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    ///Function for Switching between modes (so the search mode will appearing)
    ///The modes will be switch whenever the user tap on the Search Bar
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
}

