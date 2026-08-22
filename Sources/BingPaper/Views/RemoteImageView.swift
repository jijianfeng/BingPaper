import SwiftUI
import AppKit

enum RemoteImageState {
    case loading
    case success(NSImage)
    case failure
}

/// A preview image loader that keeps at most one request alive for this view.
///
/// `AsyncImage` is convenient, but repeatedly changing its URL while requests are
/// still pending can leave many short-lived loads competing under a weak network.
/// This loader explicitly cancels the previous task and ignores stale responses.
@MainActor
private final class RemoteImageLoader: ObservableObject {
    @Published private(set) var state: RemoteImageState = .loading

    private static let cache = NSCache<NSURL, NSImage>()
    private var task: Task<Void, Never>?
    private var requestedURL: URL?

    func load(_ url: URL?) {
        task?.cancel()
        task = nil
        requestedURL = url

        guard let url else {
            state = .failure
            return
        }

        if let cachedImage = Self.cache.object(forKey: url as NSURL) {
            state = .success(cachedImage)
            return
        }

        state = .loading
        task = Task { [weak self] in
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 15
                let (data, response) = try await URLSession.shared.data(for: request)
                try Task.checkCancellation()

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let image = NSImage(data: data) else {
                    throw URLError(.cannotDecodeContentData)
                }

                guard let self, self.requestedURL == url else { return }
                Self.cache.setObject(image, forKey: url as NSURL)
                self.state = .success(image)
            } catch {
                guard !Task.isCancelled,
                      let self,
                      self.requestedURL == url else { return }
                self.state = .failure
            }
        }
    }

    func cancel() {
        requestedURL = nil
        task?.cancel()
        task = nil
    }
}

struct RemoteImageView<Content: View>: View {
    let url: URL?
    @ViewBuilder let content: (RemoteImageState) -> Content

    @StateObject private var loader = RemoteImageLoader()

    var body: some View {
        content(loader.state)
            .onAppear {
                loader.load(url)
            }
            .onChange(of: url) { newURL in
                loader.load(newURL)
            }
            .onDisappear {
                loader.cancel()
            }
    }
}
