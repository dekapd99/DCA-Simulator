import UIKit
import Combine

class SearchTableViewController: UITableViewController {
    
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
    @Published private var searchQuery = String() ///Observe variables whenever it changes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        observeForm()
//        performSearch()
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }
    
    private func observeForm() {
        
        ///debounce used as a response time whenever the search result comes up (split seconds)
        $searchQuery
            .debounce(for: .milliseconds(750), scheduler: RunLoop.main)
            .sink { [unowned self] (searchQuery) in
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { (completion) in
                        switch completion {
                        case .failure(let error):
                            print(error.localizedDescription)
                        case .finished:
                            break
                        }
                        
                    } receiveValue: { (searchResults) in
                        print(searchResults)
                    }.store(in: &subscribers)
            }.store(in: &subscribers)
    }
    
    private func performSearch() {

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
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
    
    
}

