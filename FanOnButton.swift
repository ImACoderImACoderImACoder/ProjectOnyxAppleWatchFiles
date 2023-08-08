import SwiftUI

struct FanOnButton: View {
    @ObservedObject var bluetooth: Bluetooth
    @State private var timer: Timer?
    @State private var longPressEnded = false

    init(bluetooth: Bluetooth) {
        self.bluetooth = bluetooth
    }
    
    var body: some View {
            Button(role: .none, action: {
                if (self.longPressEnded){
                    bluetooth.TurnFanOff()
                    self.longPressEnded = false
                }else{
                bluetooth.ToggleFan()
                }
            }, label: {
                if  let isFanOn = bluetooth.localIsFanOn{
                    if isFanOn{
                        Label("", systemImage: "fanblades.fill")
                            .foregroundColor(.orange)
                    } else{
                        Label("", systemImage: "fanblades")
                            .foregroundColor(.orange)
                }
            }
            })
            .simultaneousGesture(LongPressGesture(minimumDuration: 0.175).onEnded { _ in
                self.longPressEnded = true
                bluetooth.ToggleFan()
                       })
            .font(.title2)
            .padding()
    }
}

struct FanOnButton_Previews: PreviewProvider {
    static var previews: some View {
        FanOnButton(bluetooth: Bluetooth.init())
    }
}
