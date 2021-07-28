# bicycle_bubble_machine
code associated with my bicycle bubble machine

This is the code (design and microcontroller) that is associated with my bicycle bubble machine.  It wasn't designed to be shared but enough people wanted to see it/try to replicate it that I'm putting up the code mostly as is or with a few quick edits to help someone figure out how to use it if they have a good idea of what they're looking at.  As I've said elsewhere, this was a whimsical project I created, mostly for myself.

bubble_gears_bike_set.scad are the openscad files used that create the laser cut acrylic pieces that are the arm and arm/motor mounts.  At the bottom of the file are the instantiation of the necessary pieces for one arm/mount (need two of them) although pieces need to be cut out of different thicknesses of acrylic.  I just added a bunch of commentary on where those pieces go and which thickness of acrylic

bike_panel.ino is the code for a very simple arduino nano control panel that reads 4 potentiometers and sends their state to another arduino over the serial port

bike_upper.ino is the main code that drives the stepper motors, the pump and reads the serial data from the control panel.
