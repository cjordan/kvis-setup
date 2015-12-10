#!/usr/bin/env ruby

# Definitions and functions for manipulating kvis windows
#
# "require" this script as part of a "profile" script, such that this
# file contains only information on various windows and common functions.
# Add any further options that you find useful for your kvis tasks.
#
# How to include this script:
# $LOAD_PATH.unshift File.dirname(__FILE__)
# require "kvis-definitions.rb"
abort("You're using Ruby version <1.9: please upgrade.") if RUBY_VERSION < "1.9"


# Command line argument handling
require "optparse"

OptionParser.new do |opts|
    # opts.banner = "Usage: kvis-setup.rb [options]\nDumb set up script for karma's kvis. Simulates mouse movements and clicks."
    opts.on("-h", "--help", "Display this message.") {puts opts; exit}

    # sleep_time is global so you don't have to pass it annoyingly to functions
    $sleep_time = 0.01
	opts.on("-s", "--sleep_time NUM", "Specify the amount of time to sleep between actions. May be useful for slow computers or networks. Default is #{$sleep_time}s.") {|o| $sleep_time = o.to_f}

    $open_kvis = true
    opts.on("-n", "--no-kvis", "Do not open kvis with this script.") {$open_kvis = false}

    opts.on("-d", "--debug", "Prints the commands being sent to xdotool.") {$debug = true}
end.parse!


## Common "Window" class - all kvis windows inherit these properties
class Window
    # Pass in the window id so we know which window to work upon
    def initialize(id)
        @id = id
        # Resize the window to "default" if it is not already this size
        self.size_default
    end
    # Raise this window above all others (may not work for all window managers)
    def raise
        # Unsure of the proper tool to use here. "windowactivate" seems to work.
        xdotool "windowactivate #{@id}"
        sleep $sleep_time
    end
    # Move this window to new coordinates (x,y)
    def move(x, y)
        start_time = Time.now
        xdotool "windowmove #{@id} #{x} #{y}"
        while [x, y] != get_position(@id)
            abort("*** #{File.basename(__FILE__)}: Window #{@id} did not react - are you running a tiling window manager? Exiting...") if Time.now - start_time > 2
        end
    end
    # Resize this window to geometry (x,y)
    def size(x, y)
        start_time = Time.now
        xdotool "windowsize #{@id} #{x} #{y}"
        while [x, y] != get_geometry(@id)
            abort("*** #{File.basename(__FILE__)}: Window #{@id} did not react - are you running a tiling window manager? Exiting...") if Time.now - start_time > 2
        end
    end
    # Closes the current window
    # Use with care - the coordinates of the button must be specified per child window.
    # If this is run without "close" properly defined, the script will exit prematurely.
    def close
        start_time = Time.now
        is_open = true
        while is_open
            abort("*** #{File.basename(__FILE__)}: Window #{@id} did not close - your settings may need adjusting. Exiting...") if Time.now - start_time > 2
            is_open = win_is_open?(@id)
        end
    end
    # Call this function to resize the window to its default size.
    # May be useful before calling "click_on" if your window manager resizes windows haphazardly.
    def size_default
        start_time = 0
        xdotool "windowsize #{@id} #{@default.join(" ")}"
        while @default != get_geometry(@id)
            abort("*** #{File.basename(__FILE__)}: Window #{@id} did not resize - are you running a tiling window manager? Exiting...") if Time.now - start_time > 2
        end
    end
    def id
        @id
    end
end

## Primary kvis window
class Kvis < Window
    def initialize
        # Open kvis if necessary
        system("kvis &") if $open_kvis
        # Default window size. Resize if necessary.
        @default = [522, 614]
        # Run the parent method "initialize". wait_for_window_open returns the id.
        super(wait_for_window_open(:kvis))
    end
    # Open the Files window
    def files
        self.raise
        click_on_perc(@id, 5.7, 2.5)
        # Return the new window
        return Files.new
    end
    # Opens up an element from the Intensity menu
    def intensity(element)
        self.raise
        case element.downcase
        when "pseudo"
            navigate_dropdown_perc(@id, 19.2, 2.5, 0, 50)
            return Pseudo.new
        end
    end
    # Opens up an element from the Zoom menu
    def zoom(element)
        self.raise
        case element.downcase
        when "policy"
            navigate_dropdown_perc(@id, 32.5, 2.5, 0, 225)
            return Zoom_policy.new
        end
    end
    # Opens up an element from the Overlay menu
    def overlay(element)
        self.raise
        case element.downcase
        when "axis"
            navigate_dropdown_perc(@id, 44, 2.5, 0, 50)
            return Axis.new
        when "annotation"
            navigate_dropdown_perc(@id, 44, 2.5, 0, 145)
            return Annotation.new
        end
    end
    # Open the View window
    def view
        self.raise
        click_on_perc(@id, 70, 2.5)
        return View.new
    end
end

## Browser window
class Browser < Window
    def initialize
        @default = [439, 588]
        # The browser opens with kvis - do some manual identification here
        id = (xdotool("search --name '#{$ids[:browser][:title]}'").split("\n") - $ids[:browser][:id]).first
        super(id)
    end
    def close
        self.raise
        click_on(@id, 30, 15)
        super
    end
end

## Axis Labels window
class Axis < Window
    def initialize
        @default = [344, 331]
        super(wait_for_window_open(:axis))
    end
    def close
        self.raise
        click_on(@id, 30, 15)
        super
    end
    def enable
        self.raise
        click_on_perc(@id, 29.1, 4.5)
    end
    def paper_colours
        self.raise
        click_on_perc(@id, 58.1, 42.3)
    end
end

## PseudoColour window
class Pseudo < Window
    def initialize
        # Make the height bigger so we have more profiles available in reach
        @default = [418, 700]
        super(wait_for_window_open(:pseudo))
    end
    def close
        self.raise
        click_on(@id, 30, 15)
        super
    end
    def reverse
        self.raise
        click_on(@id, 130, 15)
    end
    def greyscale2
        self.raise
        click_on(@id, 230, 331)
    end
    def glynn_rogers2
        self.raise
        click_on(@id, 230, 426)
    end
    def heat
        self.raise
        click_on(@id, 230, 523)
    end
end

## Zoom policy window
class Zoom_policy < Window
    def initialize
        @default = [316, 154]
        super(wait_for_window_open(:zoom_policy))
    end
    def close
        self.raise
        click_on(@id, 30, 15)
        super
    end
    def integer_x_zoom
        self.raise
        click_on(@id, 75, 65)
    end
    def integer_y_zoom
        self.raise
        click_on(@id, 230, 65)
    end
end

## View window
class View < Window
    def initialize
        @default = [460, 249]
        super(wait_for_window_open(:view))
    end
    def close
        self.raise
        click_on_perc(@id, 6.5, 6)
        super
    end
    def marker
        self.raise
        click_on_perc(@id, 21.7, 46.2)
    end
    def movie
        self.raise
        click_on_perc(@id, 25.4, 16.1)
    end
    def profile(element)
        self.raise
        case element.downcase
        when "line"
            navigate_dropdown_perc(@id, 43.5, 16.1, 0, 50)
        when "box_sum"
            navigate_dropdown_perc(@id, 43.5, 16.1, 0, 75)
        end
        return Profile.new
    end
end

## Profile window
class Profile < Window
    def initialize
        @default = [442, 436]
        super(wait_for_window_open(:profile))
    end
    def close
        self.raise
        click_on(@id, 30, 15)
        super
    end
    def v_zoom
        click_on(@id, 100, 15)
    end
    def style(element)
        self.raise
        case element.downcase
        when "hist"
            navigate_dropdown(@id, 280, 40, 280, 90)
        end
    end
    def overlay(element)
        self.raise
        case element.downcase
        when "axis"
            navigate_dropdown(@id, 100, 40, 100, 90)
            return Axis.new
        end
    end
end

## Files window
class Files < Window
    def initialize
        # The Files window is special - it will size itself according to the files in the pwd.
        # Additionally, it seems that button placement is machine dependant.
        # Resizing is done only to be consistent with the other windows.
        @default = [400, 400]
        super(wait_for_window_open(:files))
    end
    def pin
        # The strategy for hitting buttons is to cycle through known sizes
        self.raise
        self.size(800, 55)
        click_on(@id, 225, 15)
        self.size(800, 80)
        click_on(@id, 225, 15)
    end
    # No close method exists because it's hard. Sorry.
end

## Annotation window
class Annotation < Window
    def initialize(id)
        @default = [500, 400]
        super
    end
    def close
        self.raise
        click_on(@id, 30, 390)
        super
    end
    def pin
        self.raise
        click_on(@id, 220, 390)
    end
end

## Movie window
class Movie < Window
    def initialize(id)
        @default = [355, 315]
        super
    end
    def close
        self.raise
        click_on_perc(@id, 6.5, 6)
        super
    end
end


## Functions
# Pass a command to xdotool and return its output
def xdotool(command)
    puts "\n#{command}" if $debug
    # Run xdotool with the specified command in a shell.
    # "strip" is necessary for pesky newlines
    `xdotool #{command}`.strip
end

# Move the mouse relative to the window id to (x,y) and click
def click_on(id, x, y)
    # Get the position of this window id
    position = get_position(id)
    # Add the [x, y] passed in by get_position to our x and y
    x += position[0]
    y += position[1]
    # Move the mouse to (x, y), then click
    xdotool "mousemove #{x} #{y}"
    xdotool "click 1"
    # sleep $sleep_time
end

# Click on a point in a window based on percentile position
def click_on_perc(id, x_p, y_p)
    # Get the size of the window
    size = get_geometry(id)
    # Scale the input percentage coordinates to absolute values, and click
    click_on(id, size[0]*x_p/100, size[1]*y_p/100)
end

# Select an option from a dropdown menu in a window id
# (x1,y1) represent the position of the menu button, (x2,y2) the option to be selected
def navigate_dropdown(id, x1, y1, x2, y2)
    # Get the position of this window id
    position = get_position(id)
    # Add the [x, y] passed in by position to x1, y1, x2, y2
    x1 += position[0]
    y1 += position[1]
    x2 += position[0]
    y2 += position[1]
    # It's ugly, but "moving" the mouse on and off the dropdown button works better
    xdotool "mousemove #{x1} #{y1}"
    xdotool "mousemove #{x1} #{y1-30}"
    xdotool "mousemove #{x1} #{y1}"
    xdotool "mousedown 1"
    sleep $sleep_time
    xdotool "mousemove #{x2} #{y2}"
    xdotool "mouseup 1"
    sleep $sleep_time
end

# Navigate a dropdown by it's percentile position
# This is more tricky, as the menu itself does not scale with the window.
# [x2, y2] are the absolute difference from [x_p, y_p]
def navigate_dropdown_perc(id, x_p, y_p, x2, y2)
    size = get_geometry(id)
    x1 = size[0]*x_p/100
    y1 = size[1]*y_p/100
    navigate_dropdown(id, x1, y1, x1+x2, y1+y2)
end

# Return the (x, y) position of the top-left corner of an X window
# Does not include the window decorator surrounding a window
def get_position(id)
    (`xwininfo -id #{id}`).scan(/Absolute.*:\s*(\d*)/).flatten.map{|n| n.to_i}
end

# Return the width and height of an X window
# Does not include the window decorator surrounding a window
def get_geometry(id)
    (`xwininfo -id #{id}`).scan(/(Width|Height):\s*(\d*)/).map{|n| n[1].to_i}
end

# Return the height of the window decorator
# Takes the difference between the "Relative" and "Absolute" Y coordinate
def get_win_decorator_height(id)
    (`xwininfo -id #{id}`).scan(/^.*Y:\s*(\d*)/).flatten.map{|n| n.to_i}.reduce(:-)
end

# Return the height of a bar that may be at the top of your desktop
# This function assumes that the window id is sitting just beneath this top bar
def get_top_bar_height(id)
    (`xwininfo -id #{id}`).scan(/Relative.*Y:\s*(\d*)/)[0][0].to_i
end

# If window id is open ("X Map State"), return true
def win_is_open?(id)
    (`xwininfo -id #{id}`).match(/Map State:\s*(IsViewable)/) ? true : false
end

def wait_for_window_open(window_type)
    start_time = Time.now
    id = $ids[window_type][:id]
    while (id - $ids[window_type][:id]).empty?
        output = xdotool("search --name '#{$ids[window_type][:title]}'")
        id = output.empty? ? [] : output.split("\n")
        abort("*** #{File.basename(__FILE__)}: #{window_type} didn't open in time. Exiting...") if Time.now - start_time > 2
    end
    id = (id - $ids[window_type][:id]).first
    $ids[window_type][:id].push(id)
    return id
end



### Make an array of all window title regexes
### Search for all of these at the start of the script
$ids = {kvis: {title: "kvis.*Karma", id: []},
        browser: {title: "Browser.*for display window", id: []},
        pseudo: {title: "pseudoCmapwinpopup", id: []},
        zoom_policy: {title: "zoomPolicyPopup", id: []},
        profile: {title: "Profile Window for display window", id: []},
        axis: {title: "dressingControlPopup", id: []},
        annotation: {title: "Annotation File Selector", id: []},
        files: {title: "Array File Selector", id: []},
        view: {title: "View Control for display window*", id: []}
       }
$ids.each do |w, p|
    ids = xdotool "search --name '#{p[:title]}'"
    p[:id] = ids.empty? ? [] : ids.split("\n")
end
