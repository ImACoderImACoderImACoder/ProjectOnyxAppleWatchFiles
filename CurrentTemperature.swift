import SwiftUI

struct CurrentTemperature: View {
    @ObservedObject var bluetooth: Bluetooth
    
    init(@ObservedObject bluetooth:Bluetooth) {
        self.bluetooth = bluetooth
    }
            
    var body: some View {
        let currentTemperature = bluetooth.currentTemperature/10
        let displayTemperature = (bluetooth.isF ? bluetooth.cToF(temperatureInCelcius: currentTemperature) : currentTemperature)
        let temperatureSuffix = bluetooth.isF ? "F" : "C"
        let validTemperatures = 40...230
        Text("\(validTemperatures.contains(currentTemperature) ? "\(displayTemperature)°\(temperatureSuffix)" : "")")
            .font(.largeTitle)
            .foregroundColor(.orange)
            .onTapGesture {
                if (validTemperatures.contains(currentTemperature)){
                    bluetooth.SetIsF(useF: !bluetooth.isF)
                }
                
            }
    }
}

struct CurrentTemperature_Previews: PreviewProvider {
    static var previews: some View {
        CurrentTemperature(bluetooth: Bluetooth.init())
    }
}
