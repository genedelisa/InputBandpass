//
//  ViewController.swift
//  InputBandpass
//
//  Created by Gene De Lisa on 9/7/14.
//  Copyright (c) 2014 Gene De Lisa. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var engine:AVAudioEngine!
    var EQNode:AVAudioUnitEQ!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initAudioEngine()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initAudioEngine () {
        
        engine = AVAudioEngine()
        
        EQNode = AVAudioUnitEQ(numberOfBands: 2)
        EQNode.globalGain = 1
        engine.attachNode(EQNode)

        
        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters

        filterParams.filterType = .BandPass
        
        // 20hz to nyquist
        filterParams.frequency = 5000.0
        
        //The value range of values is 0.05 to 5.0 octaves
        filterParams.bandwidth = 1.0
        
        filterParams.bypass = false
        
        // in db -96 db through 24 d
        filterParams.gain = 15.0
        
        var format = engine.inputNode.inputFormatForBus(0)
        engine.connect(engine.inputNode, to: engine.mainMixerNode, format: format)
        startEngine()
        
    }
    
    func startEngine() {
        var error: NSError?
        if !engine.startAndReturnError(&error) {
            println("error couldn't start engine")
            if let e = error {
                println("error \(e.localizedDescription)")
            }
        }
    }
    
    // https://developer.apple.com/library/prerelease/ios/documentation/AVFoundation/Reference/AVAudioUnitEQFilterParameters_Class/index.html#//apple_ref/c/tdef/AVAudioUnitEQFilterType
    // According to this ^^^ you use the globalGain property for a bandpass filter.
    // The gain filter is for Parametric and the shelf filters. But using globalGain is like using
    // the master fader on the mixer. Try them and see.
    @IBAction func gain(sender: UISlider) {
        var val = sender.value
        println(String(format: "gain %f", val))
        
        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
//        filterParams.gain = val
        EQNode.globalGain = val
    }
    
    @IBAction func bandwidth(sender: UISlider) {
        var val = sender.value
        println(String(format: "bandwidth %f", val))
        
        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.bandwidth = val

    }
    
    @IBAction func fq(sender: UISlider) {
        var val = sender.value
        println(String(format: "fq %f", val))
        
        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.frequency = val
    }
    
    
    // yes you can bypass. I wanted to test this though.
    @IBAction func useEQ(sender: UISwitch) {

        if engine.running {
            engine.stop()
        }
        
        var format = engine.inputNode.inputFormatForBus(0)
        
        if sender.on {
            println("using eq")
            engine.connect(engine.inputNode, to: EQNode, format: format)
            engine.connect(EQNode, to: engine.mainMixerNode, format: format)
            
        } else {
            println("no eq")
            engine.connect(engine.inputNode, to: engine.mainMixerNode, format: format)
        }
        
        startEngine()
    }
    
    @IBAction func bypass(sender: UISwitch) {
        var filterParams = EQNode.bands[0] as AVAudioUnitEQFilterParameters
        filterParams.bypass = sender.on
        
        if sender.on {
            println("bypass")
        } else {
            println("no bypass")
        }
    }
}

