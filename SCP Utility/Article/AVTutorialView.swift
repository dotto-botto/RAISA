//
//  AVTutorialView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 4/16/26.
//

import SwiftUI

struct AVTutorialView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            let Guide = {
                Rectangle()
                    .frame(width: 20, height: 0.5)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading) {
                Text("AVTV_READER_FUNCS").font(.title3).bold()
                
                HStack {
                    Image(systemName: "hand.point.up.left.and.text.fill").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_BOOKMARK").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "character.textbox.badge.sparkles").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_HYPERLINK").font(.subheadline)
                }

                Text("AVTV_TOP").font(.title3).bold()
                
                HStack {
                    Image(systemName: "chevron.left").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_DISMISS").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "chevron.right").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_NEXT").font(.subheadline)
                }
                
                Text("AVTV_BOT").font(.title3).bold()
                
                HStack {
                    Image(systemName: "bookmark").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_SAVE").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "info.circle").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_INFO").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_COMMENTS").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "richtext.page").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_HIDETOOLBAR").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "checkmark").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_CHECKMARK").font(.subheadline)
                }
                
                Text("AVTV_MENU").font(.title3).bold()
                
                HStack {
                    Image(systemName: "globe").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_TRANSLATE").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "list.bullet.rectangle").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_TOC").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "photo").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_BG").font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "textformat.superscript").foregroundColor(.accentColor)
                    Guide()
                    Text("AVTV_FOOTNOTE").font(.subheadline)
                }
                
            }
            .padding(.horizontal, 20)
            .navigationTitle("HELP")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    AVTutorialView()
}
