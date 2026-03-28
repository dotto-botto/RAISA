//
//  UpdateAttributeView.swift
//  SCP Utility
//
//  Created by Maximus Harding on 5/18/23.
//

import SwiftUI

/// View that allows the user to update an article's attributes.
struct UpdateAttributeView: View {
    @Binding var article: Article
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        let Guide = {
            Rectangle()
                .frame(width: 30, height: 0.5)
                .foregroundColor(.secondary)
        }
        
        VStack {
            Text(article.title)
                .font(.title)
                .padding(.vertical, 10)
            
            Group {
                HStack {
                    Text("OBJECT_CLASS")
                    if let obj = article.objclass {
                        Guide()
                        Text(obj.toLocalString())
                            .foregroundColor(obj.toColor())
                    }
                }
                
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
                            Capsule()
                                .foregroundColor(article.objclass == obj ? .accentColor : .white)
                        }
                    }
                }
                .frame(height: 45)
            }
            
            Group {
                HStack {
                    Text("ESOTERIC_CLASS")
                    if let eso = article.esoteric, eso != .unknown {
                        Guide()
                        Text(eso.toLocalString())
                    }
                }
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
                            Capsule()
                                .foregroundColor(article.esoteric == obj ? .accentColor : .white)
                        }
                    }
                }
                .frame(height: 45)
            }
            
            Group {
                Text("RISK_CLASS")
                Text("RISK_TOOLTIP")
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
                            Capsule()
                                .foregroundColor(article.risk == obj ? .accentColor : .white)
                        }
                    }
                }
                .frame(height: 45)
            }
            
            Group {
                Text("DISRUPTION_CLASS")
                Text("DISRUPTION_TOOLTIP")
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
                            Capsule()
                                .foregroundColor(article.disruption == obj ? .accentColor : .white)
                        }
                    }
                }
                .frame(height: 45)
            }
        }
        .padding(.horizontal, 8)
        .navigationTitle("UPDATE_ATTRIBUTE")
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
