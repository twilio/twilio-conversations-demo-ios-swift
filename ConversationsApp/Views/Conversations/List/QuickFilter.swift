//
//  QuickFilter.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-05-03.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct QuickFilter: View {
    @Binding var filterText: String
    @Binding var filtering: Bool
    
    // MARK: View
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(filterText.isEmpty ? Color("LightLinkTextColor") :
                                        Color("InverseTextColor"))
                    .font(.system(size: 20))
                
                TextField("", text: $filterText)
                    .modifier(PlaceholderStyle(showPlaceHolder: filterText.isEmpty,
                                               placeholder: NSLocalizedString("conversations.search.label", comment: "Placeholder text for searching conversations")))
                    .disableAutocorrection(true)
                
                if(!filterText.isEmpty) {
                    Button(action: { filterText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color("InverseTextColor"))
                            .tint(Color("BrandBackgroundColor"))
                    }
                }
            }
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 4))
            .background(Color("BrandBackgroundColor"))
            .cornerRadius(8)
            .foregroundColor(Color("InverseTextColor"))
            
            Button(action: {
                withAnimation {
                    filterText = ""
                    filtering = false
                }
            }) {
                Text("Cancel")
                    .foregroundColor(Color("InverseTextColor"))
            }
        }
    }
}

public struct PlaceholderStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if showPlaceHolder {
                    Text(placeholder)
                        .foregroundColor(Color("LightLinkTextColor"))
                        .font(.system(size: 16))
            }
            content
                .foregroundColor(Color("InverseTextColor"))
        }
    }
}
