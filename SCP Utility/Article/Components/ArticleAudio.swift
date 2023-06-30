//
//  ArticleAudio.swift
//  SCP Utility
//
//  Created by Maximus Harding on 6/21/23.
//

import AVFoundation
import MediaPlayer
import SwiftUI

struct ArticleAudio: View {
    var url: URL
    @ObservedObject private var audio = ArticleAudioPlayer()
    
    init?(component: String) {
        guard let url = matches(for: #"(?<=url=)[\s]*?https?.*?(?=]])"#, in: component)
            .first?.trimmingCharacters(in: .whitespaces) else { return nil }
        guard let url = URL(string: url) else { return nil }
                
        self.url = url
    }
    
    var body: some View {
        HStack {
//            Spacer()
//            Button {
//                if audio.isPlaying {
//                    audio.stopAudio()
//                } else {
//                    audio.playAudioFromURL(url: url)
//                }
//            } label: {
//                Text("Audio")
//                Image(systemName: audio.isPlaying ? "pause.fill" : "play.fill")
//            }
//            Spacer()
        }
        .foregroundColor(.accentColor)
    }
}

class ArticleAudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?

    @Published var isPlaying: Bool = false

    func playAudioFromURL(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
}

struct ArticleAudio_Previews: PreviewProvider {
    static var previews: some View {
        ArticleAudio(component: """
"[[include :snippets:html5player
 |type=audio
 |url= https://scp-wiki.wdfiles.com/local--files/scp-049/Addendum0491.mp3]]
""")
    }
}
