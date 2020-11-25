#
#   Chroma: all components randomly change colour together
#

*: Panic gently
Script wait 2

#   Configure all other components to listen
: Set colour poly
: Set broadcast receive on

#   Configure this component to send
Set colour poly
Set broadcast send on
