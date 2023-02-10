//
//  SoundController.swift
//  Muscat
//
//  Created by Jiwon Jung on 2023/02/02.
//

import Foundation
import AVFoundation


class SoundController {
    var backgroundMusicPlayer: AVAudioPlayer!
    var sounds: [String: AVAudioPlayer] = [:]
    
    static func preloadSoundEffect(_ filename: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else { return nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            return player
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    func load(soundNames: [String]) {
        for name in soundNames {
            let sound = SoundController.preloadSoundEffect(name)
            sounds[name] = sound
        }
    }
    
    func playEffect(name: String) {
        sounds[name]?.play()
    }
    
    func playBackgroundMusic(_ filename: String) {
        backgroundMusicPlayer = SoundController.preloadSoundEffect(filename)
        backgroundMusicPlayer?.numberOfLoops = -1
        backgroundMusicPlayer?.play()
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
}
