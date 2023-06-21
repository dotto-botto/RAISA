//
//  HTML.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/21/23.
//

import SwiftUI
import WebKit

struct ArticleHTML: View {
    @State var htmlContent: String
    @State private var viewContent: Bool = false
    var body: some View {
        Button {
            viewContent = true
        } label: {
            HStack {
                Image(systemName: "chevron.left")
                Text("TAP_FOR_HTML")
                Image(systemName: "chevron.right")
            }
        }
        .fullScreenCover(isPresented: $viewContent) {
            NavigationStack {
                ArticleHTMLWrapper(htmlContent: htmlContent)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                viewContent = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
            }
        }
    }
}

struct ArticleHTMLWrapper: UIViewRepresentable {
    let htmlContent: String
    
    init(htmlContent: String) {
        self.htmlContent = htmlContent
            .replacingOccurrences(of: "[[html]]", with: "")
            .replacingOccurrences(of: "[[/html]]", with: "")
    }

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct ArticleHTML_Previews: PreviewProvider {
    static var previews: some View {
        ArticleHTML(htmlContent: """
[[html]]
<div style="display:inline-block; width = 100%">
<div id="findbalance" class="titlebox" style="float:left">
Left side!
  <Button type="button" class="inputfield" id="submit">Submit</Button><br/>
</div>
<div id="wise" style="display:none;float:right" class="titlebox" >
Strong side!
  <Button type="button" class="inputfield" id="wiseSubmit">Submit</Button>
</div>
</div>
<script>
document.getElementById("submit").onclick= function(){
document.getElementById("findbalance").style.display = "none";
document.getElementById("wise").style.display="";
}
document.getElementById("wiseSubmit").onclick= function(){
document.getElementById("wise").style.display = "none";
document.getElementById("findbalance").style.display = "";
};
</script>
<style>
.titlebox{
  border: black 1px solid;
  padding: 10px;
  width: 40%;
  background: beige;
}
.inputfield {
padding: 2px;
margin: 2px;
}
</style>
[[/html]]
""")
    }
}
