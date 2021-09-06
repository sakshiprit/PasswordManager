import SwiftUI

struct AddContact<GenericSites: Sites>: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var sites: GenericSites

    @State private var name: String = ""
    @State private var password: String = ""
    @State private var key: String = ""

    @State private var showingErrorAlert = false
    @State private var errorAlertMessage = ""

    // monitor keyboard events to allow scrolling when it appears
    @ObservedObject private var keyboard = KeyboardResponder()


    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                Section(header: Text("Passsword")) {
                    TextField("Password", text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Key")) {
                    TextField("Key", text: $key)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                }
            }
            // add space for the keyboard
           // .padding(.bottom, keyboard.currentHeight)
            .alert(isPresented: $showingErrorAlert, content: {
                Alert(title: Text(errorAlertMessage))
            })
            .navigationBarTitle(Text("Add contact"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: { self.addContact() },
                       label: { Text("Add").padding(15) }
                )
            )
            .onAppear() {
            }
        }
    }

    func addContact() {
        guard !self.name.isEmpty else {
            errorAlertMessage = "Please provide a name"
            showingErrorAlert = true
            return
        }
        var site = Site(name: self.name)
        self.sites.add(site: site)
        do {
            let password = self.password
            let iv = "abcdefghijklmnop"
            let key256 =   "".md5Hash(str: self.key)
            let aes256 = AES(key: key256, iv: iv)
            let encryptedPassword256 = aes256?.encrypt(string: password)
            let strBase64 = encryptedPassword256!.base64EncodedString()
            let genericPwdQueryable = GenericPasswordQueryable(service: "Mypasswords")
            let secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
            try secureStoreWithGenericPwd.setValue(strBase64, for: self.name)
        } catch {
            print("i dunno")
        }
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func takePicture() {}

    func selectPhoto() {}
    
}

struct AddContact_Previews: PreviewProvider {
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
        AddContact(sites: PreviewPersons(sites: sites))
    }
}
