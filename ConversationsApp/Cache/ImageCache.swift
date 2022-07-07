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

protocol ImageCacheProtocol {

    func copyToAppCache(forSid: MediaSid, from: URL, completion: @escaping (Result<UploadableImage, MediaError>) -> Void)
    func copyToAppCache(forSid: MediaSid, from: URL) -> Result<UploadableImage, MediaError>
    func copyToAppCache(forSid: MediaSid, from: String) -> Result<UploadableImage, MediaError>
    func copyToAppCache(forSid: MediaSid, inputStream: InputStream) -> Result<URL, MediaError>
    func hasDataFor(sid: MediaSid) -> Bool
    func urlFor(sid: MediaSid) -> URL?
}

class DefaultImageCache: ImageCacheProtocol {

    let fileManager = FileManager.default
    static let shared = DefaultImageCache()

    func copyToAppCache(forSid sid: MediaSid, from urlToSave: URL, completion: @escaping (Result<UploadableImage, MediaError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let source = try? Data(contentsOf: urlToSave),
                  let copyURL = self.urlFor(sid: sid)
            else {
                return completion(.failure(.originalFileNotFound))
            }
            do {
                NSLog("[Media] Writing image from \(urlToSave) to \(copyURL)")
                try source.write(to: copyURL)
                return completion(.success(UploadableImage(url: copyURL, inputStream: InputStream(data: source))))
            } catch {
                return completion(.failure(.notAbleToCacheFile))
            }
        }
    }

    func copyToAppCache(forSid sid: MediaSid, inputStream: InputStream) -> Result<URL, MediaError> {
        guard let copyURL = urlFor(sid: sid) else {
            return .failure(.originalFileNotFound)
        }

        do {
            let bufferSize = 1024
            var sourceData = Data()
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            inputStream.open()
            while inputStream.hasBytesAvailable {
                let read = inputStream.read(buffer, maxLength: bufferSize)
                sourceData.append(buffer, count: read)
            }
            try sourceData.write(to: copyURL)
            inputStream.close()
            return .success(copyURL)
        } catch (let error) {
            NSLog("Error encountered while copying media from input stream to cache \(error)")
            return .failure(.notAbleToCacheFile)
        }
    }

    func copyToAppCache(forSid sid: MediaSid, from urlToSave: URL) -> Result<UploadableImage, MediaError> {
        guard let written = try? Data(contentsOf: urlToSave),
              let copyURL = urlFor(sid: sid)
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

    func copyToAppCache(forSid sid: MediaSid, from: String) -> Result<UploadableImage, MediaError> {
        guard let url = URL(string: from) else {
            return .failure(.invalidUrl)
        }
        return copyToAppCache(forSid: sid, from: url)
    }

    func hasDataFor(sid: MediaSid) -> Bool {
        guard let url = urlFor(sid: sid) else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    func urlFor(sid: MediaSid) -> URL? {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("imageCache") else {
            return nil
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return url.appendingPathComponent(sid)
        } catch {
            return nil
        }
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
    private var mediaSidMap = [UIImage: String]()

    private init() {}

    func load(forMediaSid mediaSid: MediaSid, url: URL, onLoaded: ((UIImage?, Error?) -> Void)?) {
        var image: UIImage?
        
        let token = imageLoader.loadImage(forMediaSid: mediaSid, url: url) { result in
            defer {
                if let image = image {
                    self.mediaSidMap.removeValue(forKey: image)
                }
            }
            do {
                image = try result.get()
                DispatchQueue.main.async {
                    onLoaded?(image, nil)
                }
            } catch(let error) {
                DispatchQueue.main.async {
                    onLoaded?(nil, error)
                }
            }
        }
        if let token = token, let image = image {
            mediaSidMap[image] = token
        }
    }
    
    func cancel(for image: UIImage) {
        if let mediaSid = mediaSidMap[image] {
            imageLoader.cancelLoad(mediaSid: mediaSid)
            mediaSidMap.removeValue(forKey: image)
        }
    }
}
