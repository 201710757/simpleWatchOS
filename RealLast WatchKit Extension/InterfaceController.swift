//
//  InterfaceController.swift
//  RealLast WatchKit Extension
//
//  Created by 김지훈 on 2022/08/14.
//

import WatchKit
import Foundation
import HealthKit
//import AVFoundation

class InterfaceController: WKInterfaceController {
//    private var session = WKExtendedRuntimeSession()
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private let configuration = HKWorkoutConfiguration()
    
    
    var count : Int = 0
    var secondsLeft : Int = 60
    var TIME : Int = 60
    var timer : Timer = Timer.init()
    
    @IBOutlet weak var countTextLabel: WKInterfaceLabel!
    @IBOutlet weak var timerText: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        self.configuration.activityType = .running
        self.configuration.locationType = .outdoor

        do {
           self.session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        } catch {
           return
        }
        
        self.session?.startActivity(with: Date())
        
        setLabel()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    func setLabel(){
        self.countTextLabel.setText("Count : \(count)")
        self.timerText.setText("Time Setting : \(secondsLeft)sec")
    }
    @IBAction func startButton() {
        count += 1
        WKInterfaceDevice.current().play(.success)
        
        self.timer.invalidate()
        self.secondsLeft = self.TIME
        setLabel()
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
            self.secondsLeft -= 1
            
            if self.secondsLeft > 0 {
                self.timerText.setText("Left Time : \(self.secondsLeft)sec")
                self.countTextLabel.setText("\(self.count) 회 하고 쉬는중..")
            }
            else{
                self.countTextLabel.setText("Count : \(self.count)")
                self.timerText.setText("End!")
                WKInterfaceDevice.current().play(.failure)
                WKInterfaceDevice.current().play(.retry)
                
                self.timer.invalidate()
            }
            
        })
    }
    
    @IBAction func countDescent() {
        count -= 1
        setLabel()
    }
    
    @IBAction func resetButtonClicked() {
        count = 0
        self.secondsLeft = self.TIME
        self.timer.invalidate()
        setLabel()
        
        WKInterfaceDevice.current().play(.stop)
    }
}
