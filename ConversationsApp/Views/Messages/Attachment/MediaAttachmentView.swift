import SwiftUI

struct MediaAttachmentView: View {
    @ObservedObject var viewModel: MessageBubbleViewModel
    @EnvironmentObject var appModel: AppModel
    @State private var isPresentingDetailView = false
    
    var body: some View {
        VStack {
            if viewModel.contentCategory == .image {
                if viewModel.image != nil {
                    Image(uiImage: viewModel.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 600)
                    .fullScreenCover(isPresented: $isPresentingDetailView) { // MARK: ios 14+
                        ImageDetailView(imageDetail: viewModel.imageDetail, isPresenting: $isPresentingDetailView)
                    }
                    .onTapGesture {
                        isPresentingDetailView.toggle()
                    }
                } else {
                    PlaceholderImage()
                        .overlay { // MARK: ios 15+
                            HStack {
                                Button(action: { doRetryImage() }) {
                                    Text("Retry Button")
                                }.hidden()
                            }
                        }
                }
            } else if viewModel.contentCategory == .file {
                HStack {
                    Image(systemName: viewModel.mediaIconName)
                        .frame(width: 24, height: 24)
                        .contentShape(Rectangle())
                        .foregroundColor(Color("WeakTextColor"))
                        
                        .padding(.trailing, 12)
                    VStack(alignment: .leading) {
                        Text(viewModel.mediaAttachmentName)
                            .padding(.bottom, 2)
                        switch viewModel.attachmentState {
                        case .notDownloaded:
                            Text(viewModel.mediaAttachmentSize)
                                .foregroundColor(Color("WeakTextColor"))
                                .font(Font.system(size: 14.0))
                                .padding(.top, 0)
                        case .downloaded:
                            Text("media.tapToOpen")
                                .foregroundColor(Color("LinkTextColor"))
                                .font(Font.system(size: 14.0))
                                .padding(.top, 0)
                        case .downloading:
                            HStack(alignment: .center) {
                                ProgressView()
                                    .tint(Color("WeakTextColor"))
                                    .scaleEffect(0.7, anchor: .center)
                                    .padding(.trailing, 2)

                                Text("media.downloading.state")
                                    .foregroundColor(Color("WeakTextColor"))
                                    .font(.system(size: 14))

                            }
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 4)
                                .fill(Color("InverseTextColor")))
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 8)
        .onAppear {
            loadMediaImageIfNeeded()
        }
    }
    
    private func loadMediaImageIfNeeded() {
        guard (viewModel.contentCategory == .image) else { return }
        
        appModel.getMediaAttachmentURL(for: viewModel.source.messageIndex, conversationSid: viewModel.source.conversationSid) { url in
            viewModel.getImage(for: url)
        }
    }
    
    init(_ model: MessageBubbleViewModel) {
        self.viewModel = model
    }
    
    func doRetryImage() {}

}

class MediaAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        let appModel = AppModel(inMemory: true)
        let bubbles: [PersistentMessageDataItem.Decode] = load("testMessages.json")
        let currentUser = "user00"
        let managedObjectContext = appModel.getManagedContext()

        List {
              ForEach(0..<10) { n in
            MediaAttachmentView(MessageBubbleViewModel(message: bubbles[4].message(inContext: managedObjectContext), currentUser: currentUser))
                MediaAttachmentView(MessageBubbleViewModel(message: bubbles[8].message(inContext: managedObjectContext), currentUser: currentUser))//TODO: file attachment
                 }
        }
        .previewLayout(.fixed(width: .infinity, height: .infinity))
        .environmentObject(appModel)
    }
}


