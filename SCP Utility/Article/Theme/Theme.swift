//
//  Theme.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/26/23.
//

import SwiftUI

protocol RAISATheme {
    var themeName: String { get }
    var keyword: String { get }
    var themeAccent: Color { get }
}

// https://scp-wiki.wikidot.com/theme:black-highlighter-theme
struct BlackHighlighter: RAISATheme {
    var themeName: String = "Black Highlighter"
    var keyword: String = "theme:black-highlighter"
    var themeAccent: Color = Color("Buccaneer")
}

// https://scp-wiki.wikidot.com/theme:basalt
struct BasaltTheme: RAISATheme {
    var themeName: String = "Basalt"
    var keyword: String = "theme:basalt"
    var themeAccent: Color = Color("Avery")
}

// https://scp-wiki.wikidot.com/theme:space
struct SpaceTheme: RAISATheme {
    var themeName: String = "Generic Space Theme"
    var keyword: String = "theme:space"
    var themeAccent: Color = Color("Space Blue")
}
