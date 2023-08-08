import SwiftUI

struct BLEDisconnect: View {
    
    @ObservedObject var bluetooth: Bluetooth
    init(bluetooth: Bluetooth) {
        self.bluetooth = bluetooth
    }
    
    
    var body: some View {
        Button(role: .none, action: {
            bluetooth.DisconnectVolcano()
        }, label: {
                    Label("", systemImage: "peacesign")
                        .foregroundColor(.orange)
        
        })
    }
}

struct BLEDisconect_Previews: PreviewProvider {
    static var previews: some View {
        BLEDisconnect(bluetooth: Bluetooth.init())
    }
}
