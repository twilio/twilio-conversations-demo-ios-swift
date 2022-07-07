//
//  NoSearchResultsView.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-03.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct NoSearchResultsView: View {
    var body: some View {
        Spacer()
        Text("search.no_results.label")
            .font(.system(size: 20, weight: .bold))
        Text("search.different_search_item.label")
            .font(.system(size: 16))
            .foregroundColor(Color.textWeak)
            .padding(.top, 4)
    }
}
