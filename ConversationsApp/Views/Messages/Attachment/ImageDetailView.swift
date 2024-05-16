//
//  ImageDetailView.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 2/14/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct ImageDetail {
    var username: String
    var deliveryDetails: String
    var image: UIImage
}

struct ImageDetailView: View {
    
    @State var imageDetail: ImageDetail
    @Binding var isPresenting: Bool
    @State private var isShowingDetails = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("TextColor").edgesIgnoringSafeArea(.all)
                VStack(alignment: .center) {
                    ReceiptDetailedView(username: imageDetail.username, deliveryDetails: imageDetail.deliveryDetails)
                        .opacity(isShowingDetails ? 1 : 0)
                    VStack(alignment: .center
                    ) {
                        Image(uiImage: imageDetail.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 600)
                    }
                    .onTapGesture {
                        withAnimation() {
                            isShowingDetails.toggle()
                        }
                    }
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: onTapCloseButton) {
                            Image(systemName: "xmark")
                                .frame(width: 24, height: 24)
                                .contentShape(Rectangle())
                        }
                        .opacity(isShowingDetails ? 1 : 0)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareButton(itemsToShare: [imageDetail.image])
                            .opacity(isShowingDetails ? 1 : 0)
                    }
                }
                .navigationBarTitle(Text(""), displayMode: .inline)
            }
        }
    }
    
    // MARK: Private functions
    private func onTapCloseButton() {
        isPresenting.toggle()
    }
}

struct ReceiptDetailedView: View {
    
    let username: String
    let deliveryDetails: String
    
    var body: some View {
        HStack {
            DefaultAvatar()
            VStack(alignment: .leading) {
                Text(username)
                    .foregroundColor(Color("InverseTextColor"))
                    .font(Font.system(size: 14.0))
                Text(deliveryDetails)
                    .foregroundColor(Color("InverseTextColor"))
                    .font(Font.system(size: 14.0))
            }
            Spacer()
        }
        .padding()
    }
}


struct ImageDetailView_Previews: PreviewProvider {
    @State private static var isPresenting = true
    @State private static var isShowingDetails = true
    private static var image = UIImage(named: "avatar")!
    
    @State private static var imageDetailPortrait = ImageDetail(username: "Test User", deliveryDetails: "Sent Aug, 12 3:45 pm", image: image)
    
    static var previews: some View {
        ImageDetailView(imageDetail: imageDetailPortrait, isPresenting: $isPresenting)
            .previewLayout(.fixed(width: .infinity, height: .infinity))
            .previewDisplayName("Portrait")
    }
}
