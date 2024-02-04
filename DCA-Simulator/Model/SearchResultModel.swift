import Foundation

struct SearchResults: Decodable {
    let items: [SearchResult]
    
    enum CodingKeys: String, CodingKey {
        case items = "bestMatches"
    }
}

struct SearchResult: Decodable {
    let symbol: String
    let name: String
    let type: String
    let currency: String
    
    /// This Enum has a purpose to represent / reflect the propeties of the API
    /// The result of API Key Value of Properties can be seen below
    /// It is very rare / unique that they use numbering in each properties
    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case currency = "8. currency"
    }
}

//MARK: - VANTAGE API KEY VALUE OF PROPERTIES
///"1. symbol": "AMZN",
///"2. name": "Amazon.com Inc",
///"3. type": "Equity",
///"4. region": "United States",
///"5. marketOpen": "09:30",
///"6. marketClose": "16:00",
///"7. timezone": "UTC-04",
///"8. currency": "USD",
///"9. matchScore": "0.8571"
