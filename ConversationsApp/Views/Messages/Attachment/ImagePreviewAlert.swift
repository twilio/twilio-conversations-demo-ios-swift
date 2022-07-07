//
//  ImagePreviewAlert.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-31.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct ImagePreviewAlert: View {
    let viewModel: MessageListViewModel
    var errorText: String? = nil
    
    var onConfirm: (() -> Void)?
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 0) {
                VStack(spacing: 0) {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .padding(EdgeInsets(top: 11, leading: 16, bottom: 8, trailing: 16))
                    } else {
                        Image("preview_image")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 150)
                            .padding(EdgeInsets(top: 11, leading: 16, bottom: 8, trailing: 16))
                    }
                        
                    VStack(spacing: 8) {
                        Text("\(viewModel.getAttachmentFileSize()), \(viewModel.getAttachmentFileExtension()) image")
                            .font(.system(size: 14))
                            .foregroundColor(Color("WeakTextColor"))
                            
                        if let error = errorText, !error.isEmpty {
                            Text(error)
                                .font(.system(size: 14))
                                .foregroundColor(Color("ErrorTextColor"))
                                .multilineTextAlignment(.center)
                        }
                            
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
                    
                    if (errorText == nil) {
                        Divider()
                        
                        Button() {
                            onConfirm?()
                            viewModel.isPresentingImagePreview.toggle()
                        } label: {
                            Text("message.attachment.preview.send")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color("LinkTextColor"))
                                .font(.system(size: 16, weight: .medium))
                                .padding([.top, .bottom], 10)
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // do nothing, tapping here won't dismiss the custom alert
                }
                
                Divider()
                
                Button() {
                    viewModel.isPresentingImagePreview.toggle()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(Color("LinkTextColor"))
                        .font(.system(size: 16))
                        .padding([.top, .bottom], 10)
                }
            }
            .background(Color("LightBackgroundColor"))
            .cornerRadius(8)
            .frame(maxWidth: 256)
        }
        .frame(maxHeight: .infinity)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.2))
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.isPresentingImagePreview.toggle()
        }
    }
}

struct ImagePreviewAlert_Previews: PreviewProvider {
    static let viewModel = MessageListViewModel()
    static let errorText: String? = nil
    
    static var previews: some View {
        VStack {
            ImagePreviewAlert(viewModel: viewModel, errorText: errorText)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .background(.gray)
    }
}
