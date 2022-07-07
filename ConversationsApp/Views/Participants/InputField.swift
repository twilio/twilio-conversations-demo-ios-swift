//
//  InputField.swift
//  ConversationsApp
//
//  Created by Robert Ziehl on 2022-03-02.
//  Copyright © 2022 Twilio, Inc. All rights reserved.
//

import SwiftUI

struct InputField : View {
    @Binding var text: String
    @Binding var error: String
    
    var title: String
    var description: String
    var prefix: String = ""
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        Text(title)
            .font(Font.system(size: 14, weight: .medium))
            .foregroundColor(Color("WeakTextColor"))
            .padding(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))
        
        HStack(alignment: .center, spacing: 0) {
            if (!prefix.isEmpty) {
                Text(prefix)
                    .font(Font.system(size: 16))
                    .foregroundColor(Color("TextColor"))
            }

            TextField(placeholder, text: $text)
                .autocapitalization(.none)
                .keyboardType(keyboardType)
                .font(Font.system(size: 16.0))
                .foregroundColor(Color("TextColor"))
                .onChange(of: text) { _ in
                    error = ""
                }
                
            Spacer()
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .leading)
                        .aspectRatio(1, contentMode: .fit)
                        .foregroundColor(Color("TextIconColor"))
                        .tint(.blue)
                }
            }
        }.padding(16)
        
        Divider()
            .background(error.isEmpty ? Color("LightBorderColor") : Color("ErrorBorderColor"))
            .padding(.leading, 16)
        
        Text(error.isEmpty ? description : error)
            .font(Font.system(size: 14))
            .foregroundColor(error.isEmpty ? Color("WeakTextColor") : Color("ErrorTextColor"))
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16))
    }
}

struct InputField_Previews: PreviewProvider {
    @State static private var text = ""
    @State static private var error = "This input is invalid."

    static var previews: some View {
        InputField(text: $text, error: $error, title: "Field Name", description: "A description of what this field is for", prefix: "+", placeholder: "1234567890")
    }
}
