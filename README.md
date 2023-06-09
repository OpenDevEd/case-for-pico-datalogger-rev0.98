# case-for-pico-datalogger-rev1.00

Box/lid for 
* https://github.com/bablokb/pcb-pico-datalogger (Rev 0.98)
The lid will fit (CamdenBoss BIM2006/16-GY/GY ABS Case Grey 190 x 110 x 60mm 2000 Series)[https://www.camdenboss.com/camden-boss/bim200616-gygy-2000-series-general-purpose-abs-enclosure%2c-grey%2c-abs-ul94-hb%2c-190x110x60mm/c-23/p-15857].

Additional PCB to hold sensors:
* https://github.com/OpenDevEd/sensor-stripboard-v1

Uses: 
* QR Code generator for OpenSCAD https://github.com/ridercz/OpenSCAD-QR
* https://github.com/KitWallace/openscad/blob/master/braille.scad
* https://www.thingiverse.com/thing:668210/files
* https://github.com/adafruit/Adafruit_CAD_Parts

# Sensors intended for this lid.

The slots are labeled in the model. The sensors used are
* AHT20	Adafruit Qw/St:	temperature, humidity
* mcp9808	Adafruit, headers only:	temperature
* AMB2301	Wired sensor:	temperature, humidity
* SHT45	Adafruit Qw/St:	temperature, humidity
* BH1750	Adafruit Qw/St:	Luminance
* BH1745	Pimoroni Garden:	Luminance, colour
* LTR 559	Pimoroni Garden:	Luminance, proximity (~5cm)
* I2S MEMS	Adafruit, headers only:	sound

# About

The code is fairly modular. 
