import Foundation

public actor BingAPIService {
    public static let shared = BingAPIService()
    
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }
    
    public func fetchWallpapers(count: Int = 8, market: String = "zh-CN") async throws -> [BingImage] {
        guard let url = URL(string: "https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=\(count)&mkt=\(market)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(BingResponse.self, from: data)
        return decoded.images
    }
    
    public func downloadImageData(from urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
