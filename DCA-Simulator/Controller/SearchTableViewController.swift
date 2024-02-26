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
                ///Preventing searchQuery results to be nil: fixes bug whenever user open the apps it will be showing loading animation
                guard !searchQuery.isEmpty else { return }
                
                ///Showing animation when the User wait for 750 ms for the Search Results
                showLoadingAnimation()
                
                self.apiService.fetchSymbolsPublisher(keywords: searchQuery).sink { [weak self] (completion) in
                    ///Showing animation when the User wait for 750 ms for the Search Results
                    self?.hideLoadingAnimation()
                    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.item]
            let symbol = searchResult.symbol
            handleSelection(for: symbol, searchResult: searchResult)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleSelection(for symbol: String, searchResult: SearchResult) {
        showLoadingAnimation()
        
        ///MAKING API CALL
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol).sink { [weak self] (completionResult) in
            self?.hideLoadingAnimation()
            
            switch completionResult {
            case .failure(let error):
                print(error)
            case .finished: break
            }
        } receiveValue: { [weak self] (timeSeriesMonthlyAdjusted) in
            self?.hideLoadingAnimation()
            
            let asset = AssetModel(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
            self?.performSegue(withIdentifier: "showCalculator", sender: asset)
            print("success: \(timeSeriesMonthlyAdjusted.getMonthInfos())")
        }.store(in: &subscribers)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        ///Ensuring the Identifier is showing Calculator, Ensuring the Navigation Destination to show the CalculatorTableViewController, and Ensuring show the Asset
        if segue.identifier == "showCalculator",
            let destination = segue.destination as? CalculatorTableViewController,
            let asset = sender as? AssetModel {
                destination.asset = asset
        }
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

