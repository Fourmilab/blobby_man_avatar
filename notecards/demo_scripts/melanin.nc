
#   Randomly morph among skin colours approximating
#   various amounts of eumelanin.

*: Panic gently

#   Uncomment to change more rapidly
#Set time change 5
#*: Set time tick 0.1

*: Set colour HSV
#   Set initial colour to avoid the "purple peril"
*: Set colour <0.077, 0.33, 0.25>

Set colour minimum <0.077, 0.33, 0.25>
Set colour maximum <0.1, 0.74, 1>

#   Configure this component to send
Set broadcast send on

#   Configure all other components to listen
: Set broadcast receive on

*: Set colour poly
