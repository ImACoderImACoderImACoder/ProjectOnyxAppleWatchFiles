import Foundation

class Masks{
let HeatingMask = 0x0020
let FanMask = 0x2000
let DisplayOnCoolingMask = 0x1000
let DisplayOffCoolingMask: Int
let CelciusMask = 0x200
let FahrenheitMask: Int
let VibrationOnMask = 0x400
    let VibrationOffMask: Int
    init() {
        DisplayOffCoolingMask = 0x10000 + DisplayOnCoolingMask
            FahrenheitMask = 0x10000 + CelciusMask
        VibrationOffMask = 0x10000 + VibrationOnMask
    }
}
