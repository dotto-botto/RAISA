//
//  AboutView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/9/23.
//

import SwiftUI
import MarkdownUI

struct AboutView: View {
    var body: some View {
        Form {
            Markdown(apiLicense)
            
            Section("LIBRARIES") {
                NavigationLink("LIST_OF_LIBRARIES") {
                    List {
                        Link("Alamofire", destination: URL(string: "https://github.com/Alamofire/Alamofire")!)
                        Link("Kingfisher", destination: URL(string: "https://github.com/onevcat/Kingfisher")!)
                        Link("Swift Markdown UI", destination: URL(string: "https://github.com/gonzalezreal/swift-markdown-ui")!)
                        Link("SwiftSoup", destination: URL(string: "https://github.com/scinfu/SwiftSoup")!)
                        Link("SwiftyJSON", destination: URL(string: "https://github.com/SwiftyJSON/SwiftyJSON")!)
                    }
                    .navigationTitle("LIST_OF_LIBRARIES")
                }
            }
            
            Section("CONTENT_LICENSE") {
                Markdown(contentLicense)
            }
        }
        .navigationTitle("ABOUT_RAISA")
    }
    
    private var apiLicense: String = """
    This app uses the [Crom API](https://crom.avn.sh/) and is a mobile reader for the [SCP Wiki](https://scp-wiki.wikidot.com/).
    """
    
    private var contentLicense: String = """
Unless otherwise specified, all articles along with their images are available under a [Creative Commons Attribution-ShareAlike License](https://creativecommons.org/licenses/by-sa/3.0/).
"""
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AboutView()
        }
    }
}
