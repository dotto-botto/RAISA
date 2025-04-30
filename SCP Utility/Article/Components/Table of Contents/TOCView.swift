//
//  TOCView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 11/23/24.
//

import SwiftUI

struct TOCView: View {
    @State var toc: TOC
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    var body: some View {
        NavigationStack {
            Group {
                if toc.headers.isEmpty {
                    Text("TOCV_NO_HEADERS")
                        .padding(.vertical, 300)
                        .foregroundColor(.secondary)
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Divider()
                            ForEach(Array(zip(toc.headers, toc.headers.indices)), id: \.0) { header, index in
                                Button {
                                    dismiss()
                                    openURL(URL(string: "raisa://toc/\(index)")!)
                                } label: {
                                    HStack {
                                        Text(header.slice(from: " ") ?? header)
                                            .font(.headline)
                                            .padding(5)
                                        Spacer()
                                    }
                                }
                                Divider()
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                }
            }
            .navigationTitle("TOCV_TITLE")
        }
    }
}

#Preview("Default") {
    TOCView(toc: placeHolderTOC)
}

#Preview("Empty") {
    TOCView(toc: .init(headers: []))
}
