# Rangefinder
SWL addon displaying whether main-hand or off-hand weapon abilities are in range. Main-hand weapon indicator is shown on the left side of the reticle, off-hand weapon indicator is shown on the right side of the reticle.

If an enemy-targeted ability is equipped, this addon will show a red indicator when the target is out of that weapon's range. 

Note that it doesn't work with ground-targeted or player-based AoE abilities or abilities that have a nonstandard range. If a valid ability isn't equipped for one weapon, that indicator is hidden.

## Screenshots 
Both weapons out of range:

![Both weapons out of range](screens/rangefinder_bothout.PNG) 

Off-hand weapon out of range:

![Off-hand weapon out of range](screens/rangefinder_offout.PNG) 

## Customization
The spacing and size of the indicators can be adjusted with the following commands:

horizontal offset: `/setoption rf_hoffset #` (default 150)

size: `/setoption rf_fontsize #` (default 60)
