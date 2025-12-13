//
//  Theme.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/26/23.
//

import SwiftUI

// MARK: - Protocol
protocol RAISATheme {
    var themeName: String { get }
    var keyword: String { get }
    var themeAccent: Color { get }
}

// extension allows some values to be optional
extension RAISATheme {
    var logo: Image? { get { return nil } }
    var wallpaper: AnyView? { get { return nil } }
    var preferredScheme: ColorScheme? { get { return nil } }
}

let allThemes: [RAISATheme] = [
    BasaltTheme(),
    SpaceTheme(),
    CreepypastaTheme(),
    FlopstyleDarkTheme(),
    IsolatedTerminalTheme(),
    BlackHighlighter(),
]

// MARK: - Themes
// https://scp-wiki.wikidot.com/theme:black-highlighter-theme
struct BlackHighlighter: RAISATheme {
    let themeName: String = "Black Highlighter"
    let keyword: String = "theme:black-highlighter"
    let themeAccent: Color = Color("Buccaneer")
}

// https://scp-wiki.wikidot.com/theme:basalt
struct BasaltTheme: RAISATheme {
    let themeName: String = "Basalt"
    let keyword: String = "theme:basalt"
    let themeAccent: Color = Color("Avery")
}

// https://scp-wiki.wikidot.com/theme:space
struct SpaceTheme: RAISATheme {
    let themeName: String = "Generic Space Theme"
    let keyword: String = "theme:space"
    let themeAccent: Color = Color("Space Blue")
    let logo: Image = Image("spacelogo")
    let wallpaper = AnyView(SpaceThemeBackground())
    let preferredScheme: ColorScheme = .dark
}

struct SpaceThemeBackground: View {
    @Environment(\.colorScheme) var scheme
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                VStack {
                    Spacer()
                    Image("spacefooter")
                        .resizable()
                        .scaledToFit()
                }
                .ignoresSafeArea()
                .background {
                    Image("spacebg")
                }
                .opacity(scheme == .dark ? 1 : 0.5)
            } else {
                VStack {
                    Spacer()
                    Image("spacefooter")
                        .resizable()
                        .scaledToFit()
                }
                .background {
                    Image("spacebg")
                }
                .opacity(scheme == .dark ? 1 : 0.5)
            }
        }
    }
}

// https://scp-wiki.wikidot.com/theme:creepypasta
struct CreepypastaTheme: RAISATheme {
    let themeName: String = "Creepypasta"
    let keyword: String = "theme:creepypasta"
    let themeAccent: Color = Color("Para")
    let wallpaper = AnyView(Color("ParaBlack"))
    let preferredScheme: ColorScheme = .dark
}

// https://scp-wiki.wikidot.com/theme:flopstyle-dark
struct FlopstyleDarkTheme: RAISATheme {
    let themeName: String = "Flopstyle: Dark"
    let keyword: String = "theme:flopstyle-dark"
    let themeAccent: Color = Color("Bright Tyrian Pink")
    let logo: Image = Image("Flopstyle Logo")
    let wallpaper = AnyView(Color("FlopstyleBlack"))
    let preferredScheme: ColorScheme = .dark
}

// https://scp-wiki.wikidot.com/theme:isolated-terminal
struct IsolatedTerminalTheme: RAISATheme {
    let themeName: String = "Isolated Terminal"
    let keyword: String = "theme:isolated-terminal"
    let themeAccent: Color = Color("Ray Yellow")
    let wallpaper = AnyView(IsolatedTerminalBackground())
}

struct IsolatedTerminalBackground: View {
    @Environment(\.colorScheme) var scheme
    var body: some View {
        if scheme == .dark {
            LazyVStack(spacing: 0) {
                ForEach(0..<200) { _ in
                    Rectangle()
                        .foregroundColor(Color("Ray Yellow"))
                        .frame(height: 5)
                    Rectangle()
                        .foregroundColor(Color("Vacuum Dark"))
                        .frame(height: 5)
                }
                .brightness(0.7)
            }
            .overlay {
                Color.black.opacity(0.8)
            }
        } else {
            LazyVStack(spacing: 0) {
                ForEach(0..<200) { _ in
                    Rectangle()
                        .foregroundColor(Color("Ray Yellow"))
                        .frame(height: 8)
                    Rectangle()
                        .foregroundColor(Color("Vacuum Dark"))
                        .frame(height: 8)
                }
                .brightness(0.8)
                .opacity(0.7)
            }
        }
    }
}

struct Theme_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArticleView(scp: placeHolderArticle)
                .background {
                    SpaceTheme().wallpaper
                }
        }
        .tint(SpaceTheme().themeAccent)
        .previewDisplayName("Space")
        .environment(\.colorScheme, SpaceTheme().preferredScheme)
        
        NavigationStack {
            ArticleView(scp: placeHolderArticle)
                .background {
                    IsolatedTerminalTheme().wallpaper
                }
        }
        .tint(IsolatedTerminalTheme().themeAccent)
        .previewDisplayName("Isolated Terminal")
    }
}
