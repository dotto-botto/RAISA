//
//  LoginView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 11/10/25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @State private var showAlert: Bool = false
    @State private var loading: Bool = false
    @State private var storeInKeychain: Bool = false
    @EnvironmentObject var loginMonitor: LoginMonitor
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack {
            VStack {
                TextField("", text: $username, prompt: Text("USERNAME"))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("", text: $password, prompt: Text("PASSWORD"))
                Toggle("Save login information in Keychain?", isOn: $storeInKeychain)
                    .padding(.vertical, 20)
                Button("SUBMIT") {
                    loading = true
                    login()
                }
            }
            
            if loading {
                ProgressView()
            }
        }
        .padding(.horizontal, 20)
        .disabled(loading)
        .alert("INVALID_CREDENTIALS", isPresented: $showAlert) {
            Button("OK") {
                showAlert = false
            }
        }
        .navigationTitle("SIGN_IN")
    }
    
    func login() {
        RaisaReq.login(username: username, password: password, saveInKeychain: storeInKeychain) { err in
            if err != nil {
                showAlert = true
            } else {
                loginMonitor.isLoggedIn = true
                dismiss()
            }
            
            loading = false
        }
    }
}

#Preview {
    LoginView()
}
