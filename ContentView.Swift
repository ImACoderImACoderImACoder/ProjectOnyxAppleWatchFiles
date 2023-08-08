import SwiftUI

struct ContentView: View {
    @ObservedObject  var bluetooth = Bluetooth.init()

    var body: some View {
        CurrentTemperature(bluetooth: bluetooth)
                let targetTemperature = Int(bluetooth.targetTemperature)/10
                let displayTemperature = (bluetooth.isF ? bluetooth.cToF(temperatureInCelcius: targetTemperature) : targetTemperature)
                let temperatureSuffix = bluetooth.isF ? "F" : "C"
                Text("\(displayTemperature)°\(temperatureSuffix)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .onTapGesture {
                        bluetooth.SetIsF(useF: !bluetooth.isF)
                    }
                    .focusable()
                    .digitalCrownRotation(detent: $bluetooth.targetTemperature, from: 1700, through: 2300, by: 10,sensitivity: .high, isContinuous: false,
                                                  isHapticFeedbackEnabled: true) { event in
                            } onIdle: {
                                bluetooth.TurnHeatOn()
                                bluetooth.WriteTargetTemperature(tempInCelcius: Int(bluetooth.targetTemperature))
                            }
                HStack{
                    FanOnButton(bluetooth: bluetooth)
                    HeatOnButton(bluetooth: bluetooth)
                    BLEDisconnect(bluetooth: bluetooth)
                }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
