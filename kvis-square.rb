#!/usr/bin/env ruby

# A "dumb" set up script for kvis, simulating mouse movements and clicks.
# This is a profile script for a "square" configuration.


$LOAD_PATH.unshift File.dirname(__FILE__)
require "kvis-definitions.rb"


# Record the mouse position so we can reset it when done
original_mouse_pos = (xdotool "getmouselocation").scan(/:(\d*)/)[0..1].join(" ")

# Get the desktop geometry so we can place windows neatly at the edges
screen_geometry = (`xwininfo -root`).scan(/(Width|Height):\s*(\d*)/).map{|n| n[1].to_i}


## Window manipulation
# Create a new "Kvis" object
kvis = Kvis.new
# From the main kvis window, open the Axis Labels window
axis = kvis.overlay("axis")

# Disable "Integer zooms" in x and y
zoom_policy = kvis.zoom("policy")
zoom_policy.integer_x_zoom
zoom_policy.integer_y_zoom
zoom_policy.close

# Set axis labels to be enabled, along with paper colours
axis.enable
axis.paper_colours
axis.close

# Set the colour scale to "Heat", and disable the "Reverse" option
pseudo = kvis.intensity("pseudo")
pseudo.reverse
pseudo.heat
pseudo.close

# Open the View window and enable "Show Marker in Line Profile"
view = kvis.view
view.marker
# Open the "Box Sum" profile
profile = view.profile("box_sum")

# Enable "Auto V Zoom" and set the "Style" to "hist"
profile.v_zoom
profile.style("hist")
# Open the Axis Labels window for the profile window
axis = profile.overlay("axis")

# Enable Axis Labels and paper colours
axis.enable
axis.paper_colours
axis.close

# Open the Files window
files = kvis.files
# Set the Pin option
files.pin


## Window formatting variables
# Window decorator height
win_dec_height = get_win_decorator_height(kvis.id)
# Window manager top bar height - this assumes the main kvis window is positioned just beneath it
top_bar_height = get_top_bar_height(kvis.id)

# Files window (sitting on the left)
files_width = 500
files_height = screen_geometry[1] - 2*top_bar_height - win_dec_height - 4
files_x = 0
files_y = top_bar_height

# Main kvis window
kvis_width = 800
kvis_height = 800
kvis_x = files_width + 2
kvis_y = top_bar_height

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
kvis.raise

files.size(files_width, files_height)
files.move(files_x, files_y)
files.raise

browser = Browser.new
browser.size(browser_width, browser_height)
browser.move(browser_x, browser_y)
browser.raise

profile.size(profile_width, profile_height)
profile.move(profile_x, profile_y)
profile.raise

# Close the View window
view.close


## Return the mouse to where we started
xdotool "mousemove #{original_mouse_pos}"

## Done!
puts "*** #{File.basename(__FILE__)}: Done."
