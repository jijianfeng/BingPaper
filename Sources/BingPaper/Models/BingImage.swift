import Foundation

public struct BingResponse: Codable {
    public let images: [BingImage]
    
    public init(images: [BingImage]) {
        self.images = images
    }
}

public struct BingImage: Identifiable, Codable, Equatable, Hashable {
    public var id: String { hsh.isEmpty ? urlbase : hsh }
    public let startdate: String
    public let fullstartdate: String?
    public let enddate: String?
    public let url: String
    public let urlbase: String
    public let copyright: String
    public let copyrightlink: String?
    public let title: String
    public let hsh: String
    
    // 收藏与本地持久化扩展属性
    public var isFavorite: Bool?
    public var localFilePath: String?
    public var favoritedAt: Date?

    public var uhdUrlString: String {
        return "https://cn.bing.com\(urlbase)_UHD.jpg"
    }

    public var hdUrlString: String {
        return "https://cn.bing.com\(url)"
    }

    public var fullCopyrightLink: URL? {
        guard let link = copyrightlink, !link.isEmpty else { return nil }
        if link.starts(with: "http") {
            return URL(string: link)
        }
        return URL(string: "https://cn.bing.com\(link)")
    }
    
    public var formattedDate: String {
        guard startdate.count == 8 else { return startdate }
        let year = startdate.prefix(4)
        let month = startdate.dropFirst(4).prefix(2)
        let day = startdate.suffix(2)
        return "\(year)-\(month)-\(day)"
    }
}
