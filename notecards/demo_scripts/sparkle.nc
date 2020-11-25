
#   Rapid change among vivid colours

*: Panic gently
Script wait 2

*: Set time change 0.1
*: Set time tick 0.1

#   Only need to set this in primary, as it's send to other components
Set colour HSV

#   In HSV space, restrict to bright, saturated colours
Set colour min <0, 0.5, 0.5>
Set colour max <1, 1, 1>

*: Set colour poly
