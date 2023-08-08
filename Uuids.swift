import Foundation
import CoreBluetooth
enum VolcanoCbUuids{
    case PrimaryServiceUuidVolcano1
    case PrimaryServiceUuidVolcano2
    case PrimaryServiceUuidVolcano3
    case PrimaryServiceUuidVolcano4
    case PrimaryServiceUuidVolcano5
    case Register1Uuid
    case Register2Uuid
    case Register3Uuid
    case HeatOffUuid
    case HeatOnUuid
    case FanOffUuid
    case FanOnUuid
    case BleFirmwareVersionUuid
    case SerialNumberUuid
    case VolcanoFirmwareVersionUuid
    case BleServerUuid
    case BleDeviceUuid
    case HoursOfOperationUuid
    case CurrentTemperatureUuid
    case WriteTemperatureUuid
    case AutoShutoffUuid
    case AutoShutoffSettingUuid
    case LEDbrightnessUuid
}

struct CBUuidService{
    static func GetCharacteristicCBUuid(uuid: VolcanoCbUuids) -> CBUUID{
        switch(uuid){
        case .HeatOnUuid:
            return CBUUID(string: "1011000f-5354-4f52-5a26-4249434b454c")
        case .HeatOffUuid:
            return CBUUID(string: "10110010-5354-4f52-5a26-4249434b454c")
        case .BleServerUuid:
            return CBUUID(string: "00000000-0000-0000-0000-000000000069")
        case .BleDeviceUuid:
            return CBUUID(string: "00000000-0000-0000-0000-000000000420")
        case .HoursOfOperationUuid:
            return CBUUID(string: "10110015-5354-4f52-5a26-4249434b454c")
        case .CurrentTemperatureUuid:
            return CBUUID(string: "10110001-5354-4f52-5a26-4249434b454c")
        case .WriteTemperatureUuid:
            return CBUUID(string: "10110003-5354-4f52-5a26-4249434b454c")
        case .AutoShutoffUuid:
            return CBUUID(string: "1011000c-5354-4f52-5a26-4249434b454c")
        case .AutoShutoffSettingUuid:
            return CBUUID(string: "1011000d-5354-4f52-5a26-4249434b454c")
        case .LEDbrightnessUuid:
            return CBUUID(string: "10110005-5354-4f52-5a26-4249434b454c")
        case .FanOffUuid:
            return CBUUID(string: "10110014-5354-4f52-5a26-4249434b454c")
        case .FanOnUuid:
            return CBUUID(string: "10110013-5354-4f52-5a26-4249434b454c")
        case .BleFirmwareVersionUuid:
            return CBUUID(string: "10100004-5354-4f52-5a26-4249434b454c")
        case .SerialNumberUuid:
            return CBUUID(string: "10100008-5354-4f52-5a26-4249434b454c")
        case .VolcanoFirmwareVersionUuid:
            return CBUUID(string: "10100003-5354-4f52-5a26-4249434b454c")
        case .Register1Uuid:
             return CBUUID(string: "1010000c-5354-4f52-5a26-4249434b454c")
        case .Register2Uuid:
            return CBUUID(string: "1010000d-5354-4f52-5a26-4249434b454c")
        case .Register3Uuid:
            return CBUUID(string: "1010000e-5354-4f52-5a26-4249434b454c")
        case .PrimaryServiceUuidVolcano1:
            return CBUUID(string: "00000001-1989-0108-1234-123456789abc")
        case .PrimaryServiceUuidVolcano2:
            return CBUUID(string: "01000002-1989-0108-1234-123456789abc")
        case .PrimaryServiceUuidVolcano3:
            return CBUUID(string: "10100000-5354-4f52-5a26-4249434b454c")
        case .PrimaryServiceUuidVolcano4:
            return CBUUID(string: "10110000-5354-4f52-5a26-4249434b454c")
        case .PrimaryServiceUuidVolcano5:
            return CBUUID(string: "10130000-5354-4f52-5a26-4249434b454c")
        }
    }
}
