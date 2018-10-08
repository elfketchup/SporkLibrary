//
//  SMAudioManager.swift
//  SporkLibrary
//
//  Created by James on 10/6/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import AVFoundation


// MARK: - Constants

let SMAudioManagerDefaultMusicExtension         = "mp3"
let SMAudioManagerDefaultSoundEffectExtension   = "caf"


// MARK: - SMAudioManager

class SMAudioManager {
    
    var backgroundMusic : AVAudioPlayer? = nil
    
    var soundEffects = NSMutableDictionary()
    
    // MARK: - SFX
    
    func addSoundEffect(filename:String) {
        guard let audioObject = SMAudioSoundFromFile(filename: filename) else {
            print("[SMAudioManager] ERROR: Could not load sound effect from file: \(filename)")
            return
        }
        
        soundEffects.setValue(audioObject, forKey: filename)
    }
    
    func soundEffectNamed(filename:String) -> AVAudioPlayer? {
        if let audioObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            return audioObject
        }
        
        return nil
    }
    
    func setSoundEffectLoopCount(filename:String, numberOfLoops:Int) {
        if let audioObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            audioObject.numberOfLoops = numberOfLoops
        }
    }
    
    func removeSoundEffect(filename:String) {
        if let audioObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            // stop this audio if it's playing
            if audioObject.isPlaying == true {
                audioObject.stop()
            }
            
            soundEffects.removeObject(forKey: filename)
        }
    }
    
    func playSoundEffect(filename:String, playFromBeginning:Bool) {
        if let existingSound = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            // start playing from the beginning of the sound effect
            if playFromBeginning == true {
                existingSound.pause()
                existingSound.currentTime = 0
            }
            existingSound.play()
        } else {
            // no sound effect found, so try to create it first
            addSoundEffect(filename: filename)
            
            // try one more time to play it
            if let soundObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
                soundObject.play()
            }
        }
    }
    
    func playSoundEffect(filename:String) {
        playSoundEffect(filename: filename, playFromBeginning: false)
    }
    
    
    // MARK: - Music handling
    
    func playBackgroundMusic(filename:String, loopForever:Bool) {
        self.stopBackgroundMusic()
        
        guard let audioObject = SMAudioSoundFromFile(filename: filename) else {
            print("[SMAudioManager] ERROR: Could not load music from file named: \(filename)")
            return
        }
        
        if loopForever == true {
            audioObject.numberOfLoops = -1
        }
        
        audioObject.play()
        backgroundMusic = audioObject
    }
    
    func playBackgroundMusic(filename:String) {
        self.playBackgroundMusic(filename: filename, loopForever: false)
    }
    
    func musicIsPlaying() -> Bool {
        if backgroundMusic != nil {
            return backgroundMusic!.isPlaying
        }
        
        return false // no music
    }
    
    func pauseBackgroundMusic() {
        if backgroundMusic != nil {
            if backgroundMusic!.isPlaying == true {
                backgroundMusic!.pause()
            }
        }
    }
    
    func stopBackgroundMusic() {
        if backgroundMusic == nil {
            return
        }
        
        if backgroundMusic!.isPlaying == true {
            backgroundMusic!.stop()
        }
    }
    
    // removes the audio data entirely
    func removeBackgroundMusic() {
        self.stopBackgroundMusic()
        backgroundMusic = nil
    }
}
