//
//  MediaAttachmentHelper.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 3/7/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation

struct MediaAttachmentHelper {
    
    var appModel: AppModel
    
    func startDownloadingMedia(for messageIndex: Int64, media: PersistentMediaDataItem?, conversationSid: String?, completion: @escaping (MediaAttachmentState)-> ()) {
        guard let conversationSid = conversationSid,
              let mediaURL = MediaAttachmentHelper.getDownloadedFileURL(for: media) else {
                  return
              }
        appModel.getMediaAttachmentURL(for: messageIndex, conversationSid: conversationSid) { url in
            guard let mediaUrl = url else {
                print("Error trying to get url to download media attachment.")
                return
            }
            completion(.downloading)
            
            let downloadTask = URLSession.shared.downloadTask(with: mediaUrl) { url, httpURLResponse, error in
                guard error == nil,
                      let fileURL = url else {
                          DispatchQueue.main.async {
                              completion(.notDownloaded)
                          }
                          return
                      }
                do {
                    try FileManager.default.moveItem(at: fileURL, to: mediaURL)
                    
                    DispatchQueue.main.async {
                        completion(.downloaded)
                    }
                } catch {
                    print("Error saving file: \(error)")
                }
            }
            downloadTask.resume()
        }
    }
    
    static func doesFileExist(for media: PersistentMediaDataItem?) -> Bool {
        guard let mediaURL = getDownloadedFileURL(for: media) else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: mediaURL.path)
    }
    
    static func getDownloadedFileURL(for media: PersistentMediaDataItem?) -> URL? {
        guard let media = media,
              let mediaSid = media.sid,
              !mediaSid.isEmpty else {
            return nil
        }
        
        var mediaURL = mediaSid
        
        if let filename = media.filename, !filename.isEmpty {
            let sanitizedFilename = filename.replacingOccurrences(of: " ", with: "_")
            
            if let url = URL(string: sanitizedFilename) {
                mediaURL = "\(mediaSid).\(url.pathExtension)"
            }
        }

        do {
            let documentsURL = try
            FileManager.default.url(for: .documentDirectory,
                                       in: .userDomainMask,
                                       appropriateFor: nil,
                                       create: false)
            return documentsURL.appendingPathComponent(mediaURL)
        } catch {
            print("Error finding file: \(error)")
            return nil
        }
    }
}
