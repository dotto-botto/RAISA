//
//  EditorView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/11/23.
//

import SwiftUI

struct EditorView: View {
    @State var title: String = ""
    @State private var query: String = ""
    @State private var bodyText: String = ""
    @State private var showAlert: Bool = false
    @State private var showPreview: Bool = false
    @State private var showInfo: Bool = false
    @State private var lastAddedText: String = ""
    var body: some View {
        VStack(alignment: .leading) {
            Text("BODY").font(.title2).bold()
            TextEditor(text: $bodyText)
        }
        .padding(.horizontal, 20)
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("PREVIEW", action: {showPreview = true})
                    .disabled(bodyText == "" || title == "")
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                Button {
                    
                } label: {
                    Image(systemName: "bookmark")
                }
                Spacer()
                Button {
                    bodyText = bodyText.replacingOccurrences(of: lastAddedText, with: "")
                } label: {
                    Image(systemName: "arrow.uturn.left")
                }
                
                Menu {
                    Button {
                        bodyText += """
[[include :scp-wiki:component:anomaly-class-bar-source
|item-number=123
|clearance=1
|container-class=euclid
|secondary-class=thaumiel
|secondary-icon=http://scp-wiki.wikidot.com/local--files/component:anomaly-class-bar/thaumiel-icon.svg
|disruption-class=ekhi
|risk-class=notice
]]
"""
                    } label: {
                        Label("ACS", systemImage: "square.stack.3d.up")
                    }
                    
                    Button {
                        bodyText += """
[[collapsible show="show" hide="hide"]]
TEXT
[[/collapsible]]
"""
                    } label: {
                        Label("COLLAPSIBLE", systemImage: "plusminus")
                    }
                    
                    Button {
                        bodyText += "[[image https://scp-wiki.wikidot.com/local--files/component:object-warning-box-source/scp-logo.svg]]"
                    } label: {
                        Label("Image", systemImage: "photo")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: bodyText) { _ in
            lastAddedText = bodyText
        }
        .fullScreenCover(isPresented: $showPreview) {
            NavigationStack {
                ArticleView(scp: Article(
                    title: title,
                    pagesource: bodyText,
                    url: placeholderURL
                ), dismissText: "EDITOR")
                .toolbar(.hidden, for: .bottomBar)
            }
        }
        .sheet(isPresented: $showInfo) {
            SyntaxGuideView()
        }
        .alert("SET_TITLE", isPresented: $showAlert) {
            TextField(title, text: $query)
            
            Button("OK") {
                showAlert = false
                title = query
            }
            Button("CANCEL", role: .cancel) {
                showAlert = false
            }
        }
        .onAppear {
            if title.isEmpty {
                showAlert = true
            }
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditorView(title: "My SCP")
        }
    }
}
