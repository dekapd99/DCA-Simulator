import Foundation
import Combine

/// VANTAGE ALPHA API
/// https://www.alphavantage.co/support/#api-key

struct APIService {
    ///Encoding Error
    enum APIServiceError: Error {
        case encodingError
        case badRequest
    }
    
    ///Randomly selecting 1 of 3 API Keys because of RESTRICTION
    var API_KEY: String {
        return keys.randomElement() ?? ""
    }
        
    /// Containing 3 API Key because 1 Key can only give you a response of 5 calls per-minute
    /// Needs to be done this way because of Free API Service that has a lot of RESTRICTION
    let keys = ["QLQXFENUCJ0M2CBD", "WDWXRZIJVMMI3K6U", "QN9X9QJBFP76XUC9"]
    
    ///Fetching Symbols from Endpoint API URL
    func fetchSymbolsPublisher(keywords: String) -> AnyPublisher<SearchResults, Error> {
        
        let result = parseQuery(text: keywords)
        var symbol = String()
        
        switch result {
        case .success(let query):
            symbol = query
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        ///Code encoding for "keywords"
        guard let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        { return Fail(error: APIServiceError.encodingError).eraseToAnyPublisher() }
        
        let urlString = "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(symbol)&apikey=\(API_KEY)"
        
        let urlResult = parseURL(urlString: urlString)
        
        switch urlResult {
        case .success(let url):
            ///MAKING THE API CALL
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({ $0.data }) ///Get Data
                .decode(type: SearchResults.self, decoder: JSONDecoder()) ///Decode the JSON Data to SearchResult
                .receive(on: RunLoop.main) ///Receive the Decoded Data to Main Thread
                .eraseToAnyPublisher() ///Wraps the Publisher as a type of Eraser
            
        case .failure(let error): ///Return Bad Request (ERROR)
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func fetchTimeSeriesMonthlyAdjustedPublisher(keywords: String) -> AnyPublisher<TimeSeriesMonthlyAdjustedModel, Error> {
        
        let result = parseQuery(text: keywords)
        var symbol = String()
        
        switch result {
        case .success(let query):
            symbol = query
        case .failure(let error):
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        ///Code encoding for "keywords"
        guard let keywords = keywords.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else
        { return Fail(error: APIServiceError.encodingError).eraseToAnyPublisher() }
        
        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbol)&apikey=\(API_KEY)"
        
        let urlResult = parseURL(urlString: urlString)
        
        switch urlResult {
        case .success(let url):
            ///MAKING THE API CALL
            return URLSession.shared.dataTaskPublisher(for: url)
                .map({ $0.data }) ///Get Data
                .decode(type: TimeSeriesMonthlyAdjustedModel.self, decoder: JSONDecoder()) ///Decode the JSON Data to SearchResult
                .receive(on: RunLoop.main) ///Receive the Decoded Data to Main Thread
                .eraseToAnyPublisher() ///Wraps the Publisher as a type of Eraser
            
        case .failure(let error): ///Return Bad Request (ERROR)
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    private func parseQuery(text: String) -> Result<String, Error> {
        
        if let query = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return .success(query)
        } else {
            return .failure(APIServiceError.encodingError)
        }
    }
    
    private func parseURL(urlString: String) -> Result<URL, Error> {
        if let url = URL(string: urlString) {
            return .success(url)
        } else {
            return .failure(APIServiceError.badRequest)
        }
    }
}
