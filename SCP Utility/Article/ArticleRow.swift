//
//  ArticleItem.swift
//  SCP Wiki Utility
//
//  Created by Maximus Harding on 12/30/22.
//

import SwiftUI

/// The main view used to display articles that are saved by the user.
/// Meant to be used inside of a List or a VStack.
struct ArticleRow: View {
    @Binding var article: Article
    @EnvironmentObject var subtitlesStore: SubtitlesStore
    @Environment(\.colorScheme) var colorScheme

    @State private var showArticle = false
    @State private var showUpdateView = false
    @State private var showListAddView = false
    @State private var loading = false
    @State private var compImgName = ""

    var body: some View {
        Button { showArticle = true } label: {
            rowContent
        }
        .frame(height: 50)
        .contextMenu { contextMenu }
        .disabled(loading)
        .sheet(isPresented: $showUpdateView) {
            NavigationStack { UpdateAttributeView(article: $article) }
        }
        .fullScreenCover(isPresented: $showArticle) {
            NavigationStack { ArticleView(scp: article) }
        }
        .sheet(isPresented: $showListAddView) {
            ListAdd(isPresented: $showListAddView, article: article)
        }
        .task { computeCompImg() }
    }

    private var rowContent: some View {
        HStack {
            VStack(spacing: 3) {
                HStack {
                    Text(article.title).lineLimit(1)
                    if let subtitle = RaisaReq.getAlternateTitle(url: article.url, store: subtitlesStore), !subtitle.isEmpty {
                        Rectangle().frame(width: 5, height: 1).foregroundColor(.accentColor)
                        Text(subtitle).lineLimit(1)
                    }
                    if article.isComplete() {
                        Image(systemName: "checkmark").foregroundColor(.accentColor)
                    }
                    Spacer()
                }
                .foregroundColor(.primary)
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .resizable().scaledToFit()
                        .frame(width: 15, height: 14)
                    Text(article.findLanguage()?.toAbbr() ?? "")
                    Text(article.currenttext ?? "...")
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Spacer()
                }
            }
            Spacer()
            compImgView
        }
    }

    private var compImgView: some View {
        Group {
            if colorScheme == .light {
                Image(compImgName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
            } else {
                Image(compImgName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 30, height: 30)
                    .colorInvert()
            }
        }
    }

    private var contextMenu: some View {
        Group {
            Button { showArticle = true } label: {
                Label("OPEN_IN_READER", systemImage: "rectangle.portrait.and.arrow.forward")
            }
            Divider()
            Button { updateArticleSource() } label: {
                Label("UPDATE_ARTICLE", systemImage: "square.and.arrow.down")
            }
            Button { showListAddView = true } label: {
                Label("LISTADDVIEW_TITLE", systemImage: "bookmark")
            }
            Button { showUpdateView = true } label: {
                Label("UPDATE_ATTRIBUTE", image: article.objclass?.toImage() ?? "euclid-icon")
            }
            Button(role: .destructive) {
                PersistenceController.shared.deleteArticleEntity(id: article.id)
                loading = true
            } label: {
                Label("DELETE", systemImage: "trash")
            }
        }
    }

    private func updateArticleSource() {
        loading = true
        RaisaReq.pageSourceFromURL(url: article.url) { source, error in
            defer { loading = false }
            guard error == nil, let source else { return }
            var updated = article
            updated.updateSource(source)
            updated.downloadImages(ignoreUserPreference: true)
            PersistenceController.shared.updatePageSource(id: updated.id, newPageSource: source)
        }
    }

    private func computeCompImg() {
        if let im = article.esoteric?.toImage(), !im.isEmpty {
            compImgName = im
        } else if let im = article.objclass?.toImage(), !im.isEmpty, article.objclass != .esoteric {
            compImgName = im
        }
    }
}
