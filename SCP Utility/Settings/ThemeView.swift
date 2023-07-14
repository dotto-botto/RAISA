//
//  ThemeView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 7/12/23.
//

import SwiftUI

struct ThemeView: View {
    var body: some View {
        VStack {
            List {
                ForEach(Array(zip(allThemes.map { $0.themeName }, allThemes)), id: \.0) { _, theme in
                    NavigationLink(theme.themeName) {
                        ArticleView(scp: placeHolderArticle, theme: theme)
                            .background {
                                theme.wallpaper
                            }
                            .tint(theme.themeAccent)
                    }
                }
            }
        }
        .navigationTitle("TV_TITLE")
    }
}

struct ThemeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack { ThemeView() }
    }
}
