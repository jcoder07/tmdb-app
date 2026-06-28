import UIKit

extension UIImageView {
    /// Loads an image from a URL asynchronously. Returns a cancellable Task.
    @discardableResult
    func loadImage(from url: URL?) -> Task<Void, Never>? {
        image = nil
        guard let url else { return nil }
        return Task { [weak self] in
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data),
                  !Task.isCancelled else { return }
            await MainActor.run { self?.image = image }
        }
    }
}
