//
//  ContentView.swift
//  BetterRest
//
//  Created by Nicholas Verrico on 9/21/21.
//

import SwiftUI

struct ContentView: View {

    @State private var wakeup = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components)!
    }
    
    var body: some View {
        NavigationView{
            Form{
                Text("When do you want to wake up?")
                    .font(.headline)
                
                DatePicker("Please enter a time", selection: $wakeup, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    // Not compatible with macOS or tvOS
                    .datePickerStyle(WheelDatePickerStyle())
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
               
                
                Text("Daily coffee intake")
                    .font(.headline)
                
                Stepper(value: $coffeeAmount, in: 1...20){
                    if coffeeAmount == 1{
                        Text("1 cup")
                    } else {
                        Text("\(coffeeAmount) cups")
                    }
                }
            }
            .navigationBarTitle("Better Rest")
            .navigationBarItems(trailing: Button(action: calculateBedtime){
                Text("Calculate")
            })
        }
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        })
        
    }
        
        
        func calculateBedtime(){
          
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            do {
                let model = try SleepCalculator(configuration: .init())
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                let sleepTime = wakeup - prediction.actualSleep
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                alertMessage = formatter.string(from: sleepTime)
                alertTitle = " Your ideal bedtime is..."
                
            } catch{
                alertTitle = "Error"
                alertMessage = "Sorry there was a probelm calculating your bedtime."
            }
            showingAlert = true
            
            
        }
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
