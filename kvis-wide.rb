#!/usr/bin/env ruby

# A "dumb" set up script for kvis, simulating mouse movements and clicks.
# This is a profile script for a "wide" configuration.
# This script assumes the main kvis window is on top when it is run.


# This line assumes that the kvis definitions library is in the
# same dir as this script.
require "#{__FILE__.match(/(\/.*\/)/)}kvis-definitions.rb"


# Record the mouse position so we can reset it when done
original_mouse_pos = (xdotool "getmouselocation").scan(/:(\d*)/)[0..1].join(' ')

# Get the desktop geometry so we can place windows neatly at the edges
screen_geometry = (`xwininfo -root`).scan(/(Width|Height):\s*(\d*)/).map{|n| n[1].to_i}


## Window manipulation
# Create a new "Kvis" object from a window id that matches "kvis.*Karma"
kvis = Kvis.new(get_window_id("kvis.*Karma"))
# From the main kvis window, open the Axis Labels window
kvis.raise
kvis.overlay("axis")

# Set axis labels to be enabled, along with paper colours
axis = Axis.new(get_window_id("dressingControlPopup"))
axis.enable
axis.paper_colours
axis.close

# Set the colour scale to "Glynn Rogers2", and disable the "Reverse" option
kvis.intensity("pseudo")
pseudo = Pseudo.new(get_window_id("pseudoCmapwinpopup"))
pseudo.reverse
pseudo.glynn_rogers2
pseudo.close

# Open the View window and enable "Show Marker in Line Profile"
# kvis.view
# view = View.new(get_window_id("View Control for display window"))
view = kvis.view
view.marker
# Open the "Box Sum" profile
view.profile("box_sum")
# Close the View window
view.raise
view.close

# Enable "Auto V Zoom" and set the "Style" to "hist"
profile = Profile.new(get_window_id("Profile Window for display window"))
profile.raise
profile.v_zoom
profile.style("hist")
# Open the Axis Labels window for the profile window
profile.overlay("axis")

# Enable Axis Labels and paper colours
axis = Axis.new(get_window_id("dressingControlPopup"))
axis.enable
axis.paper_colours
axis.close

# Open the Files window
kvis.raise
kvis.files
files = Files.new(get_window_id("Array File Selector"))
# Set the Pin option
files.pin


## Window formatting variables
kvis_id = get_window_id("kvis.*Karma")
# Window decorator height
win_dec_height = get_win_decorator_height(kvis_id)
# Window manager top bar height - this assumes the main kvis window is positioned just beneath it
top_bar_height = get_top_bar_height(kvis_id)

# Main kvis window
kvis_width = 1400
kvis_height = 700
kvis_x = 0
kvis_y = top_bar_height

# Files window (sitting on the left)
files_width = 500
files_height = screen_geometry[1] - 2*top_bar_height - win_dec_height - 4
files_x = 0
files_y = top_bar_height

# Browser (sitting on the right)
browser_width = 500
browser_height = 600
browser_x = screen_geometry[0] - browser_width - 4
browser_y = top_bar_height

# Profile window (sitting on the right)
profile_width = browser_width
profile_height = screen_geometry[1] - 2*top_bar_height - browser_height - 2*win_dec_height - 6
profile_x = screen_geometry[0] - browser_width - 4
profile_y = top_bar_height + browser_height + 2*win_dec_height + 2


## Move and resize all the windows
kvis.size(kvis_width, kvis_height)
kvis.move(kvis_x, kvis_y)

files.size(files_width, files_height)
files.move(files_x, files_y)

browser = Browser.new(get_window_id("Browser.*for display window"))
browser.size(browser_width, browser_height)
browser.move(browser_x, browser_y)

profile.size(profile_width, profile_height)
profile.move(profile_x, profile_y)


## Return the mouse to where we started
xdotool "mousemove #{original_mouse_pos}"

## Done!
