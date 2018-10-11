//
//  SMAudioManager.swift
//  SporkLibrary
//
//  Created by James on 10/6/18.
//  Copyright © 2018 James Briones. All rights reserved.
//

import AVFoundation

/*
 SMAudioManager
 
 A basic class for playing sound effects and background music. This only stores a single AVAudioPlayer instance for music,
 and stores multiple instances of it for sound effects.
 */
class SMAudioManager {
    
    /*
     A single instance of AVAudioPlayer, used for playing background music. A more advanced music playing class could
     probably be used to fade-in/fade-out music, or change music to fit the mood, but for this class, just playing
     one background music file will do. :P
    */
    var backgroundMusic : AVAudioPlayer? = nil
    
    /*
     Stores multiple AVAudioPlayer objects, using the filename as the key in the dictionary's key-value storage.
     */
    var soundEffects = NSMutableDictionary()
    
    // MARK: - SFX
    
    // loads a single audio file into memory by filename, and stores it into the sound effects mutable dictionary
    func addSoundEffect(filename:String) {
        guard let audioObject = SMAudioSoundFromFile(filename: filename) else {
            print("[SMAudioManager] ERROR: Could not load sound effect from file: \(filename)")
            return
        }
        
        soundEffects.setValue(audioObject, forKey: filename)
    }
    
    // retrieves AVAudioPlayer object from the mutable dictionary by filename, assuming it exists
    // (returns 'nil' if audio object doesn't exist)
    func soundEffectNamed(filename:String) -> AVAudioPlayer? {
        if let audioObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            return audioObject
        }
        
        return nil
    }
    
    // set number of loops in a particular AVAudioPlayer object (assuming it exists in the sound effects dictionary)
    func setSoundEffectLoopCount(filename:String, numberOfLoops:Int) {
        if let audioObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            audioObject.numberOfLoops = numberOfLoops
        }
    }
    
    // find and remove an AVAudioPlayer object from the dictionary
    func removeSoundEffect(filename:String) {
        if let audioObject = soundEffects.object(forKey: filename) as? AVAudioPlayer {
            // stop this audio if it's playing
            if audioObject.isPlaying == true {
                audioObject.stop()
            }
            
            soundEffects.removeObject(forKey: filename)
        }
    }
    
    /*
     Plays an AVAudioPlayer object from the dictionary -- if the object doesn't exists, it's loaded from memory and then played.
     
     The 'playFromBeginning' parameter determines if the audio file is played from the beginning of the sound
     (the 00:00 position in the audio file), or not. This is only necessary if you want to FORCE the audio to
     play from the beginning.
     */
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
    
    // Plays a sound effect without needing to start from the beginning
    func playSoundEffect(filename:String) {
        playSoundEffect(filename: filename, playFromBeginning: false)
    }
    
    
    // MARK: - Music handling
    
    // Load background music into memory from an audio file
    func loadBackgroundMusic(filename:String) {
        // Remove previous background music
        removeBackgroundMusic()
        
        guard let audioObject = SMAudioSoundFromFile(filename: filename) else {
            print("[SMAudioManager] ERROR: Could not load music from file named: \(filename)")
            return
        }
        
        backgroundMusic = audioObject
    }
    
    // set how many times the background music will loop
    func setBackgroundMusicLoopCount(numberOfLoops:Int) {
        if backgroundMusic != nil {
            backgroundMusic!.numberOfLoops = numberOfLoops
        }
    }
    
    // play background music, if any exists
    func playBackgroundMusic() {
        if backgroundMusic == nil {
            print("[SMAudioManager] ERROR: Could not play background music because no audio data was loaded.")
            return
        }
        
        backgroundMusic!.play()
    }
    
    // Plays a background music audio and also determines whether it should loop forever or not
    func playBackgroundMusic(loopForever:Bool) {
        if loopForever == true {
            setBackgroundMusicLoopCount(numberOfLoops: -1)
        } else {
            setBackgroundMusicLoopCount(numberOfLoops: 0)
        }
    
        playBackgroundMusic()
    }
    
    // Loads an audio file into memory as background music, plays it, and determines whether it would loop continuously or not
    func playBackgroundMusic(filename:String, loopForever:Bool) {
        loadBackgroundMusic(filename: filename)
        playBackgroundMusic(loopForever: loopForever)
    }
    
    // Determines if music is playing or not
    func musicIsPlaying() -> Bool {
        if backgroundMusic != nil {
            return backgroundMusic!.isPlaying
        }
        
        return false // since no music exists
    }
    
    // pause any existing background music
    func pauseBackgroundMusic() {
        if backgroundMusic != nil {
            if backgroundMusic!.isPlaying == true {
                backgroundMusic!.pause()
            }
        }
    }
    
    // Completely stop any background music
    func stopBackgroundMusic() {
        if backgroundMusic == nil {
            return
        }
        
        if backgroundMusic!.isPlaying == true {
            backgroundMusic!.stop()
            backgroundMusic!.currentTime = 0 // reset to beginning of audio
        }
    }
    
    // removes the background music's audio data entirely
    func removeBackgroundMusic() {
        self.stopBackgroundMusic()
        backgroundMusic = nil
    }
}
