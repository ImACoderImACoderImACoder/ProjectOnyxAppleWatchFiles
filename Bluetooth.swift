import Foundation
import CoreBluetooth
import SwiftUI

class Bluetooth : NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    var cbCentralManager: CBCentralManager!
    var masks = Masks.init()
    @Published var currentTemperature = -1
    @Published var targetTemperature = -1.0
    @Published var isFanOn: Bool?
    @Published var isHeatOn: Bool?
    
    @Published var localIsFanOn: Bool?
    @Published var localIsHeatOn: Bool?
    
    @Published var serialNumber: String = "Loading..."
    @Published var bleFirmwareVersion: String = "Loading..."
    @Published var hoursOfOperation: String = "Loading..."
    @Published var volcanoFirmwareVersion: String = "Loading..."
    
    @Published var isDisplayOnCooling: Bool = false
    @Published var isPulseFanWhenVolcanoReachesTemperature: Bool = false
    @Published var ledBrightness = 0.0
    @Published var isF = false
    

    lazy var isDisplayOnCoolingBinding: Binding<Bool> = {
        Binding{
            self.isDisplayOnCooling
        } set: { newValue in
            self.isDisplayOnCooling = newValue
            self.ToggleIsDisplayOnCooling()
        }
    }()
    
    lazy var isPulseFanWhenVolcanoReachesTemperatureBinding: Binding<Bool> = {
        Binding{
            self.isPulseFanWhenVolcanoReachesTemperature
        } set: { newValue in
            self.isPulseFanWhenVolcanoReachesTemperature = newValue
            self.ToggleIsPulseFanWhenVolcanoReachesTemperature()
        }
    }()
    
    func isLoading() -> Bool {
        if isFanOn != nil{
        return currentTemperature > 40 && targetTemperature > 40
        } else{
            return false
        }
    }
    
    var writeTemperatureCharacteristic: CBCharacteristic?
    var fanOnCharacterisitc: CBCharacteristic?
    var fanOffCharacterisitc: CBCharacteristic?
    var heatOnCharacterisitc: CBCharacteristic?
    var heatOffCharacterisitc: CBCharacteristic?
    var register2Characterisitc: CBCharacteristic?
    var register3Characterisitc: CBCharacteristic?
    var ledBrightnessCharacteristic: CBCharacteristic?
    var currentTemperatureCharacteristic: CBCharacteristic?
    
   override init() {
       super.init()
        self.cbCentralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    func convertToggleCharacteristicToBool(value :Int, mask: Int) -> Bool {
      if value & mask == 0 {
        return false;
      }
      return true;
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn{
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = peripheral.name{
            if name.uppercased().contains("S&B VOLCANO"){
                central.stopScan()
                central.connect(peripheral, options: nil)
                volcano = peripheral
            }
        }
    }
    
    var volcano: CBPeripheral?
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected \(peripheral.name!)")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for service in services{
                switch(service.uuid.uuidString){
                case CBUuidService.GetCharacteristicCBUuid(uuid: .PrimaryServiceUuidVolcano3).uuidString:
                    peripheral.discoverCharacteristics(nil, for: service)

                case CBUuidService.GetCharacteristicCBUuid(uuid: .PrimaryServiceUuidVolcano4).uuidString:
                    peripheral.discoverCharacteristics(nil, for: service)
                default:
                    continue
                }
            }
        }
    }
    
    func dataToUnsignedBytes16(value : Data) -> Int {
        let count = value.count
        var array = [UInt8](repeating: 0, count: count)
        (value as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        let firstByte = Int(array[0])
        let secondByte = Int(array[1])
        
        return firstByte + secondByte * 256
    }
    
    func dataToUnsignedBytes8(value : Data) -> Int {
        let count = value.count
        var array = [UInt8](repeating: 0, count: count)
        (value as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        let firstByte = Int(array[0])
        
        return firstByte
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics{
            for characteristic in characteristics {
                switch(characteristic.uuid){
                case CBUuidService.GetCharacteristicCBUuid(uuid: .HeatOnUuid):
                    heatOnCharacterisitc = characteristic
                case CBUuidService.GetCharacteristicCBUuid(uuid: .HeatOffUuid):
                    heatOffCharacterisitc = characteristic
                case  CBUuidService.GetCharacteristicCBUuid(uuid: .LEDbrightnessUuid):
                    peripheral.readValue(for: characteristic)
                    ledBrightnessCharacteristic = characteristic
                    var x = Data.init()
                    let defaultBrightness = [UInt8(70)]
                    x.append(contentsOf: defaultBrightness)
                    peripheral.writeValue(x, for: characteristic, type: .withResponse)
                case CBUuidService.GetCharacteristicCBUuid(uuid: .CurrentTemperatureUuid):
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    currentTemperatureCharacteristic = characteristic
                case CBUuidService.GetCharacteristicCBUuid(uuid: .WriteTemperatureUuid):
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    writeTemperatureCharacteristic = characteristic
                    WriteTargetTemperature(tempInCelcius: 230)
                case CBUuidService.GetCharacteristicCBUuid(uuid: .FanOnUuid):
                    fanOnCharacterisitc = characteristic
                case CBUuidService.GetCharacteristicCBUuid(uuid: .FanOffUuid):
                    fanOffCharacterisitc = characteristic
                case CBUuidService.GetCharacteristicCBUuid(uuid: .Register1Uuid):
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                case CBUuidService.GetCharacteristicCBUuid(uuid: .Register2Uuid):
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    register2Characterisitc = characteristic
                case CBUuidService.GetCharacteristicCBUuid(uuid: .Register3Uuid):
                    peripheral.setNotifyValue(true, for: characteristic)
                    peripheral.readValue(for: characteristic)
                    register3Characterisitc = characteristic
                case CBUuidService.GetCharacteristicCBUuid(uuid: .SerialNumberUuid),
                    CBUuidService.GetCharacteristicCBUuid(uuid: .HoursOfOperationUuid),
                    CBUuidService.GetCharacteristicCBUuid(uuid: .VolcanoFirmwareVersionUuid),
                     CBUuidService.GetCharacteristicCBUuid(uuid: .BleFirmwareVersionUuid):
                    peripheral.readValue(for: characteristic)
                default:
                    continue
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let val = characteristic.value{
            if (characteristic.uuid == CBUuidService.GetCharacteristicCBUuid(uuid: .LEDbrightnessUuid)){
                ledBrightness = Double(dataToUnsignedBytes8(value: val))
                return
            }
            let normalizedValue = dataToUnsignedBytes16(value: val)
            switch(characteristic.uuid){
            case CBUuidService.GetCharacteristicCBUuid(uuid: .CurrentTemperatureUuid):
                currentTemperature = normalizedValue
            case CBUuidService.GetCharacteristicCBUuid(uuid: .WriteTemperatureUuid):
                targetTemperature = Double(normalizedValue)
            case CBUuidService.GetCharacteristicCBUuid(uuid: .Register1Uuid):
                isFanOn = convertToggleCharacteristicToBool(value: normalizedValue, mask: masks.FanMask)
                localIsFanOn = isFanOn
                isHeatOn = convertToggleCharacteristicToBool(value: normalizedValue, mask: masks.HeatingMask)
                localIsHeatOn = isHeatOn
            case CBUuidService.GetCharacteristicCBUuid(uuid: .Register2Uuid):
                isDisplayOnCooling = !convertToggleCharacteristicToBool(value: normalizedValue, mask: masks.DisplayOnCoolingMask)
                isF = convertToggleCharacteristicToBool(value: normalizedValue, mask: masks.FahrenheitMask)
            case CBUuidService.GetCharacteristicCBUuid(uuid: .Register3Uuid):
                isPulseFanWhenVolcanoReachesTemperature =  (normalizedValue & masks.VibrationOnMask) == 0;
            case CBUuidService.GetCharacteristicCBUuid(uuid: .SerialNumberUuid),
                CBUuidService.GetCharacteristicCBUuid(uuid: .VolcanoFirmwareVersionUuid):
                let rawValue = String(decoding: val, as: UTF8.self)
                let index = rawValue.index(rawValue.startIndex, offsetBy: 8)
                let value = String(rawValue.prefix(upTo: index))

                switch(characteristic.uuid){
                case CBUuidService.GetCharacteristicCBUuid(uuid: .VolcanoFirmwareVersionUuid):
                    volcanoFirmwareVersion = value
                case CBUuidService.GetCharacteristicCBUuid(uuid: .SerialNumberUuid):
                    serialNumber = value
                default:
                    print("This should be impossible I can't believe you see this")
                }
            case CBUuidService.GetCharacteristicCBUuid(uuid: .BleFirmwareVersionUuid):
                bleFirmwareVersion = String(decoding: val, as: UTF8.self)
            case CBUuidService.GetCharacteristicCBUuid(uuid: .HoursOfOperationUuid):
                hoursOfOperation = String(Double(normalizedValue) / 10)
            case CBUuidService.GetCharacteristicCBUuid(uuid: .LEDbrightnessUuid):
                ledBrightness = Double(normalizedValue)
            default:
                print ("Could not assign updated value of \(normalizedValue) and/or \(val) to internal state.  \(characteristic.uuid) not found in switch")
            }
        }
    }
    
    func convertToUInt32BLE(val: Int) -> Data {
         var rawData = Data.init()
        
        rawData.append(contentsOf: [UInt8(val & 255)])
        
        var tempValue = val >> 8
        rawData.append(contentsOf: [UInt8(tempValue & 255)])
        
        tempValue = tempValue >> 8
        rawData.append(contentsOf: [UInt8(tempValue & 255)])
        
        tempValue = tempValue >> 8
        rawData.append(contentsOf: [UInt8(tempValue & 255)])
         
        return rawData
    }
    
    func WriteTargetTemperature(tempInCelcius: Int){
        if let characteristic = writeTemperatureCharacteristic {
            let nextTemperature = Int(tempInCelcius / 10) * 10 //This is done to make the last digit a 0.  The volcano uses the last digit for precision but that is causing some undesireable behavior in the early UI.
            targetTemperature = Double(nextTemperature)
            let payload = convertToUInt32BLE(val: nextTemperature)
            volcano?.writeValue(payload, for: characteristic, type: .withResponse)
        }
    }
    
    func TurnFanOff(){
        volcano!.writeValue(Data([00]), for: fanOffCharacterisitc!, type: .withResponse)
        localIsFanOn = false
    }
    
    func TurnFanOn(){
        volcano!.writeValue(Data([00]), for: fanOnCharacterisitc!, type: .withResponse)
        localIsFanOn = true
    }
    
    func ToggleFan(){
        if let fanOn = localIsFanOn {
            if fanOn{
                TurnFanOff()
            } else{
                TurnFanOn()
            }
        }
    }
    
    func ToggleHeat(){
        if let heatOn = localIsHeatOn {
            if heatOn{
                volcano!.writeValue(Data([00]), for: heatOffCharacterisitc!, type: .withResponse)
                localIsHeatOn = false

            } else{
                volcano!.writeValue(Data([00]), for: heatOnCharacterisitc!, type: .withResponse)
                localIsHeatOn = true
            }
        }
    }
    
    func TurnHeatOn(){
                volcano!.writeValue(Data([00]), for: heatOnCharacterisitc!, type: .withResponse)
                localIsHeatOn = true
    }
    
    func ToggleIsDisplayOnCooling(){
        let nextMask = isDisplayOnCooling ? masks.DisplayOnCoolingMask : masks.DisplayOffCoolingMask
            let buffer = convertToUInt32BLE(val: nextMask);
            volcano!.writeValue(buffer, for: register2Characterisitc!, type: .withResponse)
    }
    
    func ToggleIsPulseFanWhenVolcanoReachesTemperature(){
        let nextMask = isPulseFanWhenVolcanoReachesTemperature ? masks.VibrationOnMask : masks.VibrationOffMask
        let buffer = convertToUInt32BLE(val: nextMask)
        volcano!.writeValue(buffer, for: register3Characterisitc!, type: .withResponse)
    }
    
    func SetIsF(useF: Bool){
        let mask = useF ? masks.FahrenheitMask : masks.CelciusMask
        let buffer = convertToUInt32BLE(val: mask)
        volcano!.writeValue(buffer, for: register2Characterisitc!, type: .withResponse)
    }

    func DisconnectVolcano(){
        self.cbCentralManager.cancelPeripheralConnection(volcano!)
        exit(0)
    }
    
    func cToF(temperatureInCelcius: Int) -> Int {
        return Int((Double(temperatureInCelcius) * 1.8 + 32).rounded())
    }
    
    func setLedBrightness(){
        var data = Data.init()
        data.append(contentsOf: [UInt8(Int(ledBrightness))])
        volcano?.writeValue(data, for: ledBrightnessCharacteristic!, type: .withResponse)
    }
    
}
