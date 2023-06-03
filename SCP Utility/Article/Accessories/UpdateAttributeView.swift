//
//  UpdateAttributeView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/18/23.
//

import SwiftUI

/// View that allows the user to update an article's attributes.
struct UpdateAttributeView: View {
    @State var article: Article
    var body: some View {
        VStack {
            Group {
                Text("Object Class")
                Text(article.objclass?.getTooltip() ?? "The standard indicator of the difficulty of containing an anomaly.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                HStack {
                    ForEach(ObjectClass.allCases.filter { $0 != .unknown }, id: \.self) { obj in
                        Button {
                            article.updateAttribute(objectClass: obj)
                        } label: {
                            Image(obj.toImage())
                                .resizable()
                                .scaledToFit()
                        }
                        .background {
                            if article.objclass == obj {
                                Capsule()
                                    .foregroundColor(.accentColor)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                .frame(height: 45)
            }
            
            Group {
                Text("Esoteric Class")
                Text(article.esoteric?.getTooltip() ?? "Used when normal object classes cannot classify this anomaly.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                HStack {
                    ForEach(EsotericClass.allCases.filter { $0 != .unknown }, id: \.self) { obj in
                        Button {
                            if article.esoteric == obj {
                                article.updateAttribute(esotericClass: .unknown)
                            } else {
                                article.updateAttribute(objectClass: .esoteric)
                                article.updateAttribute(esotericClass: obj)
                            }
                        } label: {
                            Image(obj.toImage())
                                .resizable()
                                .scaledToFit()
                        }
                        .background {
                            if article.esoteric == obj {
                                Capsule()
                                    .foregroundColor(.accentColor)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                .frame(height: 45)
            }
            
            Group {
                Text("Risk Class")
                Text("The severity of this anomaly's affects on a person.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                HStack {
                    ForEach(RiskClass.allCases.filter { $0 != .unknown }, id: \.self) { obj in
                        Button {
                            article.updateAttribute(riskClass: obj)
                        } label: {
                            Image(obj.toImage())
                                .resizable()
                                .scaledToFit()
                        }
                        .background {
                            if article.risk == obj {
                                Capsule()
                                    .foregroundColor(.accentColor)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                .frame(height: 45)
            }
            
            Group {
                Text("Disruption Class")
                Text("This anomaly's ability to disrupt the status quo.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                HStack {
                    ForEach(DisruptionClass.allCases.filter { $0 != .unknown }, id: \.self) { obj in
                        Button {
                            article.updateAttribute(disruptionClass: obj)
                        } label: {
                            Image(obj.toImage())
                                .resizable()
                                .scaledToFit()
                        }
                        .background {
                            if article.disruption == obj {
                                Capsule()
                                    .foregroundColor(.accentColor)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
                .frame(height: 45)
            }
        }
    }
}

struct UpdateAttributeView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateAttributeView(article: placeHolderArticle)
    }
}
