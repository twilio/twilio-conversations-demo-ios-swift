//
//  ImageCache.swift
//  ConversationsApp
//
//  Copyright © Twilio, Inc. All rights reserved.
//

import Foundation
import UIKit

enum MediaError: Error {

    case originalFileNotFound
    case invalidUrl
    case notAbleToCacheFile
    case notAbleToDownloadImage
}

struct UploadableImage {

    let url: URL
    let inputStream: InputStream
}

protocol ImageCache {

    func copyToAppCache(locatedAt: URL, completion: @escaping (Result<UploadableImage, MediaError>) -> Void)
    func copyToAppCache(locatedAt: URL) -> Result<UploadableImage, MediaError>
    func copyToAppCache(locatedAt: String) -> Result<UploadableImage, MediaError>
    func copyToAppCache(inputStream: InputStream) -> Result<URL, MediaError>
    func hasDataForURL(url: URL?) -> Bool
}

class DefaultImageCache: ImageCache {

    let fileManager = FileManager.default
    static let shared = DefaultImageCache()

    func copyToAppCache(locatedAt urlToSave: URL, completion: @escaping (Result<UploadableImage, MediaError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let written = try? Data(contentsOf: urlToSave),
                  let copyURL = self.createURL(for: urlToSave.lastPathComponent)
            else {
                return completion(.failure(.originalFileNotFound))
            }
            do {
                try written.write(to: copyURL)
                return completion(.success(UploadableImage(url: copyURL, inputStream: InputStream(data: written))))
            } catch {
                return completion(.failure(.notAbleToCacheFile))
            }
        }
    }

    func copyToAppCache(inputStream: InputStream) -> Result<URL, MediaError> {
        guard let copyURL = createURL(for: UUID().uuidString) else {
            return .failure(.originalFileNotFound)
        }

        do {
            let bufferSize = 1024
            var data = Data()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            inputStream.open()
            while inputStream.hasBytesAvailable {
                let read = inputStream.read(buffer, maxLength: bufferSize)
                data.append(buffer, count: read)
            }
            try data.write(to: copyURL)
            inputStream.close()
            return .success(copyURL)
        } catch (let error) {
            print("Error encountered while copying media from input stream to cache \(error)")
            return .failure(.notAbleToCacheFile)
        }
    }

    func copyToAppCache(locatedAt urlToSave: URL) -> Result<UploadableImage, MediaError> {
        guard let written = try? Data(contentsOf: urlToSave),
              let copyURL = createURL(for: urlToSave.lastPathComponent)
        else {
            return .failure(.originalFileNotFound)
        }
        do {
            try written.write(to: copyURL)
            return .success(UploadableImage(url: copyURL, inputStream: InputStream(data: written)))
        } catch {
            return .failure(.notAbleToCacheFile)
        }
    }

    func copyToAppCache(locatedAt: String) -> Result<UploadableImage, MediaError> {
        guard let url = URL(string: locatedAt) else {
            return .failure(.invalidUrl)
        }
        return copyToAppCache(locatedAt: url)
    }

    func hasDataForURL(url: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    private func createURL(for fileName: String) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return url.appendingPathComponent(fileName)
    }
}

typealias MediaSid = String

class ImageLoader {

    private var loadedImages = [MediaSid: UIImage]()
    private var runningRequests = [MediaSid: URLSessionDataTask]()

    func loadImage(forMediaSid mediaSid: MediaSid, url: URL, _ completion: @escaping (Result<UIImage, Error>) -> Void) -> String? {
        if let image = loadedImages[mediaSid] {
            completion(.success(image))
            return nil
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { self.runningRequests.removeValue(forKey: mediaSid) }

            if let data = data, let image = UIImage(data: data) {
                self.loadedImages[mediaSid] = image
                completion(.success(image))
                return
            }
            
            guard let error = error else {
                completion(.failure(MediaError.notAbleToDownloadImage))
                return
            }

            guard (error as NSError).code == NSURLErrorCancelled else {
                completion(.failure(error))
                return
            }
        }
        task.resume()
        runningRequests[mediaSid] = task
        return mediaSid
    }

    func cancelLoad(mediaSid: String) {
        runningRequests[mediaSid]?.cancel()
        runningRequests.removeValue(forKey: mediaSid)
    }
}

class UIImageLoader {

    static let loader = UIImageLoader()

    private let imageLoader = ImageLoader()
    private var mediaSidMap = [UIImageView: String]()

    private init() {}

    func load(forMediaSid mediaSid: MediaSid, url: URL, for imageView: UIImageView, onLoaded: ((Error?) -> Void)?) {
        let token = imageLoader.loadImage(forMediaSid: mediaSid, url: url) { result in
            defer { self.mediaSidMap.removeValue(forKey: imageView) }
            do {
                let image = try result.get()
                DispatchQueue.main.async {
                    imageView.image = image
                    onLoaded?(nil)
                }
            } catch(let error) {
                DispatchQueue.main.async {
                    onLoaded?(error)
                }
            }
        }

        if let token = token {
            mediaSidMap[imageView] = token
        }
    }
    
    func cancel(for imageView: UIImageView) {
        if let mediaSid = mediaSidMap[imageView] {
            imageLoader.cancelLoad(mediaSid: mediaSid)
            mediaSidMap.removeValue(forKey: imageView)
        }
    }
}
