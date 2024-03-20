//
//  ContentView.swift
//  BetterRest
//
//  Created by Ahsan Qureshi on 3/17/24.
//

import CoreML
import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
    private static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    private var idealBedtime: String {
        calculateBedtime()
    }
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section("When do you want to wake up?") {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    Section("Desired amount of sleep") {
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                    
                    Section("Daily coffee intake") {
                        Picker("Cups of coffee", selection: $coffeeAmount) {
                            ForEach(1...20, id: \.self) { coffeeAmount in
                                Text("^[\(coffeeAmount) cup](inflect: true)")
                            }
                        }.labelsHidden()
                    }
                    HStack {
                        Spacer()
                        Text(idealBedtime).font(.extraLargeTitle)
                        Spacer()
                    }
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hourInSeconds = (components.hour ?? 0) * 60 * 60
            let minuteInSeconds = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Int64(hourInSeconds + minuteInSeconds), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep
            
            let time = sleepTime.formatted(date: .omitted, time: .shortened)
            return "Your ideal bedtime is… \(time)"
        } catch {
            return "Your ideal bedtime is… ?"
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
