//
//  ContentView.swift
//  Shared
//
//  Created by Sakshi patil on 01/09/2021.
//

import SwiftUI

struct MainView<GenericSites: Sites>: View {
    @ObservedObject var sites: GenericSites
    @State private var isAlert = false
    @State var showingAddContact = false
    var secureStoreWithGenericPwd: SecureStore!
    @State var myPassword:String = ""
    @State var keyValue: String? = nil
    @State var dialogDisplayed = false
    @State var currentValue = ""

    init(sites: GenericSites) {
        let genericPwdQueryable = GenericPasswordQueryable(service: "Mypasswords")
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        self.sites = sites
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(sites.all) { person in
                    Button(action: {
                        currentValue = person.name
                        dialogDisplayed = true
                    }) {
                         Text(person.name)
                    }.buttonStyle(PlainButtonStyle())
                }
                .onDelete { offsets in
                    var sites = [Site]()
                    for offset in offsets {
                        sites.append(self.sites.all[offset])
                    }
                    self.sites.remove(sites: sites)
                }
            }
            .navigationBarTitle("Sites")
            .navigationBarItems(leading: EditButton(), trailing:
                Button(action: {
                    self.showingAddContact = true
                }) {
                    Image(systemName: "plus")
                        // increase tap area size
                        .padding(15)
                }
            )
        }
      /* .sheet(isPresented: $dialogDisplayed) {
            Dialog(prompt: keyValue == nil ? "Enter a name" : "Enter a new name", value: $keyValue)
        }
        .onChange(of: keyValue ?? "", perform: { value  in
            showPasswordEnter(text:currentValue,key: value)
        }) */
        .alert(isPresented: $dialogDisplayed, TextFieldAlert(title: "Enter key", message: "") { (text) in
                    if text != nil {
                        showPasswordEnter(text:currentValue,key: text!)
                    }
        })
        .sheet(isPresented: $showingAddContact) {
            AddContact(sites: self.sites)
        }
        .alert(isPresented: $isAlert) { () -> Alert in
            Alert(title: Text("Password"), message: Text(self.myPassword), primaryButton: .default(Text("Okay"), action: {
                self.isAlert = false
            }), secondaryButton: .default(Text("Dismiss")))
        }
      
    }
    
    func showPasswordEnter(text:String,key:String) {
        do {
            let passwordFromChain =  try secureStoreWithGenericPwd.getValue(for: text)
             let iv = "abcdefghijklmnop"
             let key256 =   "".md5Hash(str: key)
             let aes256 = AES(key: key256, iv: iv)
             let data = Data(base64Encoded: passwordFromChain!, options: .ignoreUnknownCharacters)
             let decryptedValue = aes256?.decrypt(data: data)
            if decryptedValue != nil  {
                self.myPassword = decryptedValue!
            } else {
                self.myPassword = "Wrong key entered"
            }
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isAlert = true
             }
            print(decryptedValue)
        } catch  {
            
        }
    }

    func deleteKey(sites:[Site]) {
        for site in sites {
            do {
                try secureStoreWithGenericPwd.removeValue(for: site.name)
            } catch  {}
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static let sites = [Site]()

    class PreviewPersons: Sites {
        @Published private(set) var all: [Site]
        var allPublished: Published<[Site]> { _all }
        var allPublisher: Published<[Site]>.Publisher { $all }
        init(sites: [Site]) { self.all = sites }
        func add(site: Site) { }
        func insert() { }
        func update(site: Site) { }
        func remove(sites: [Site]) { }
    }

    static var previews: some View {
        MainView(sites: PreviewPersons(sites: sites))
    }
}

/*
struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
