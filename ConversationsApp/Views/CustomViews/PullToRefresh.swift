//
//  PullToRefresh.swift
//  ConversationsApp
//
//  Created by Cecilia Laitano on 3/14/22.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

//PullToRefresh provides 'pull to refresh' for ScrollViews until SwiftUI add these APIs. Today is only available for Lists.
//Idea taken from https://stackoverflow.com/questions/56493660/pull-down-to-refresh-data-in-swiftui
//but adapted following https://developer.apple.com/documentation/swiftui/refreshaction

struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    @Environment(\.refresh) private var refresh
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .task {
                        if needRefresh {
                            needRefresh = false
                            await refresh?()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                }
                Spacer()
            }
        }.padding(.top, -50)
    }
}

struct PullToRefresh_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView(.vertical) {
            PullToRefresh(coordinateSpaceName: "pullToRefresh")
                .refreshable {
                    //load more data
                }
        }
        .coordinateSpace(name: "pullToRefresh")
    }
}
