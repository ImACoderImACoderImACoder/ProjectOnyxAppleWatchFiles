import SwiftUI

struct HeatOnButton: View {
    
    @ObservedObject var bluetooth: Bluetooth
    init(bluetooth: Bluetooth) {
        self.bluetooth = bluetooth
    }
    
    var body: some View {
            Button(role: .none, action: {
                bluetooth.ToggleHeat()
            }, label: {
                if  let isHeatOn = bluetooth.localIsHeatOn{
                    if isHeatOn{
                        Label("", systemImage: "flame.fill")
                            .foregroundColor(.orange)
                    } else{
                        Label("", systemImage: "flame")
                            .foregroundColor(.orange)
                }
            }
            })
            .font(.title2)
            .padding()
    }
}

struct HeatOnButton_Previews: PreviewProvider {
    static var previews: some View {
        HeatOnButton(bluetooth: Bluetooth.init())
    }
}
