import Foundation
import Combine

/// VANTAGE ALPHA API
/// https://www.alphavantage.co/support/#api-key

struct APIService {
    ///Randomly selecting 1 of 3 API Keys because of RESTRICTION
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
        
    /// Containing 3 API Key because 1 Key can only give you a response of 5 calls per-minute
    /// Needs to be done this way because of Free API Service that has a lot of RESTRICTION
    let keys = ["QLQXFENUCJ0M2CBD", "WDWXRZIJVMMI3K6U", "QN9X9QJBFP76XUC9"]
    
    ///Fetching Symbols from Endpoint API URL
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(keywords)&apikey=\(API_KEY)"
        
        let url = URL(string: urlString)! ///Constructing url with urlString
        
        ///MAKING THE API CALL
        return URLSession.shared.dataTaskPublisher(for: url)
            .map({ $0.data }) ///Get Data
            .decode(type: SearchResults.self, decoder: JSONDecoder()) ///Decode the JSON Data to SearchResult
            .receive(on: RunLoop.main) ///Receive the Decoded Data to Main Thread
            .eraseToAnyPublisher() ///Wraps the Publisher as a type of Eraser
    }
    
}
