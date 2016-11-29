# Convert screenshots to 1280x800
convert Screenshot_2016-11-27_22-58-53.png  -thumbnail '>x800'   -background transparent   -gravity east   -extent 1280x800   -compose Copy_Opacity      screenshot-resized-3.png

# Convert banner 480x280
convert banner.png  -thumbnail '>x280'   -background transparent   -gravity center   -extent 480x280   -compose Copy_Opacity      banner_480x280.png

# Convert banner 920x680
convert banner.png  -thumbnail '<x680'   -background transparent   -gravity center   -extent 920x680   -compose Copy_Opacity      banner_920x680.png

# Convert banner 1400x560
convert banner.png  -thumbnail '>x560'   -background transparent   -gravity center   -extent 1400x560   -compose Copy_Opacity      banner_1400x560.png
