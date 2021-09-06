//
//  Dialog.swift
//  Manager
//
//  Created by Sakshi patil on 01/09/2021.
//

import Foundation
import SwiftUI

struct Dialog: View {
    @Environment(\.presentationMode) var presentationMode

    /// Edited value, passed from outside
    @Binding var value: String?

    /// Prompt message
    var prompt: String = ""
    
    /// The value currently edited
    @State var fieldValue: String
    
    /// Init the Dialog view
    /// Passed @binding value is duplicated to @state value while editing
    init(prompt: String, value: Binding<String?>) {
        _value = value
        self.prompt = prompt
        _fieldValue = State<String>(initialValue: value.wrappedValue ?? "")
    }

    var body: some View {
        VStack {
            Text(prompt).padding()
            TextField("", text: $fieldValue)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            .frame(width: 200, alignment: .center)
            HStack {
            Button("OK") {
                self.value = fieldValue
                self.presentationMode.wrappedValue.dismiss()
            }
            Button("Dismiss") {
                self.presentationMode.wrappedValue.dismiss()
            }
            }.padding()
        }
        .padding()
    }
}

#if DEBUG
struct Dialog_Previews: PreviewProvider {

    static var previews: some View {
        var name = "John Doe"
        Dialog(prompt: "Name", value: Binding<String?>.init(get: { name }, set: {name = $0 ?? ""}))
    }
}
#endif
