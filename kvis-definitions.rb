#!/usr/bin/env ruby

# Definitions and functions for manipulating kvis windows
#
# "require" this script as part of a "profile" script, such that this
# file contains only information on various windows and common functions.
# Add any further options that you find useful for your kvis tasks.
#
# Example of inclusion line:
# require "#{__FILE__.match(/(\/.*\/)/)}kvis-definitions.rb"
# This line assumes that this script is in the same dir as a profile script.


# Command line argument handling
require 'optparse'

OptionParser.new do |opts|
    # opts.banner = "Usage: kvis-setup.rb [options]\nDumb set up script for karma's kvis. Simulates mouse movements and clicks."

    opts.on('-h','--help','Display this message.') {puts opts; exit}

    # sleep_time is global so you don't have to pass it annoyingly to functions
    $sleep_time = 0.05
	opts.on('-s','--sleep_time NUM','Specify the amount of time to sleep between actions. May be useful for slow computers or networks. Default is 0.05s.') {|o| $sleep_time = o.to_f}

    $open_kvis = true
    opts.on('-n','--no-kvis','Do not open kvis with this script.') {$open_kvis = false}

    opts.on('-d','--debug','Prints the commands being sent to xdotool.') {$debug = true}
end.parse!


## Common "Window" class - all kvis windows inherit these properties
class Window
    # Pass in the window id so we know which window to work upon
    def initialize(id)
        @id = id
        # Resize the window to "default" if it is not already this size
        xdotool "windowsize --sync #{@id} #{@default.join(' ')}" unless get_geometry(@id) == @default
    end
    # Raise this window above all others (will not work for all window managers)
    def raise
        # Unsure of the proper tool to use here. "windowactivate" seems to work
        xdotool "windowactivate #{@id}"
    end
    # Move this window to new coordinates (x,y)
    def move(x,y)
        xdotool "windowmove --sync #{@id} #{x} #{y}"
    end
    # Resize this window to geometry (x,y)
    def size(x,y)
        xdotool "windowsize --sync #{@id} #{x} #{y}"
    end
    # Closes the current window
    # Use with care - the coordinates of the button must be specified per window.
    # If this is run without "close" properly defined, the script will exit prematurely.
    def close
        abort("#{File.basename(__FILE__)}: Window #{@id} did not close - your settings may need adjusting. Exiting...") if win_is_open?(@id)
    end
end

## Primary kvis window
class Kvis < Window
    def initialize(id)
        # Default window size. Resize if necessary.
        @default = [522,614]
        # Run the parent method "initialize"
        super
    end
    # Open the Files window
    def files
        click_on(@id,30,15)
    end
    # Opens up an element from the Intensity menu
    def intensity(element)
        case element.downcase
        when "pseudo"
            navigate_dropdown(@id,100,15,100,65)
        end
    end
    # Opens up an element from the Overlay menu
    def overlay(element)
        case element.downcase
        when "axis"
            navigate_dropdown(@id,230,15,230,65)
        when "annotation"
            navigate_dropdown(@id,230,15,230,160)
        end
    end
    # Open the View window
    def view
        click_on(@id,365,15)
    end
end

## Browser window
class Browser < Window
    def initialize(id)
        @default = [439,588]
        super
    end
    def close
        click_on(@id,30,15)
        super
    end
end

## Axis Labels window
class Axis < Window
    def initialize(id)
        @default = [344,331]
        super
    end
    def close
        click_on(@id,30,15)
        super
    end
    def enable
        click_on(@id,100,15)
    end
    def paper_colours
        click_on(@id,200,140)
    end
end

## PseudoColour window
class Pseudo < Window
    def initialize(id)
        # Make the height bigger so we have more profiles available in reach
        @default = [418,700]
        super
    end
    def close
        click_on(@id,30,15)
        super
    end
    def reverse
        click_on(@id,130,15)
    end
    def greyscale2
        click_on(@id,230,331)
    end
    def glynn_rogers2
        click_on(@id,230,426)
    end
    def heat
        click_on(@id,230,523)
    end
end

## View window
class View < Window
    def initialize(id)
        @default = [460,249]
        super
    end
    def close
        click_on(@id,30,15)
        super
    end
    def marker
        click_on(@id,100,115)
    end
    def profile(element)
        case element.downcase
        when "line"
            navigate_dropdown(@id,200,40,200,90)
        when "box_sum"
            navigate_dropdown(@id,200,40,200,115)
        end
    end
end

## Profile window
class Profile < Window
    def initialize(id)
        @default = [442,436]
        super
    end
    def close
        click_on(@id,30,15)
        super
    end
    def v_zoom
        click_on(@id,100,15)
    end
    def style(element)
        case element.downcase
        when "hist"
            navigate_dropdown(@id,280,40,280,90)
        end
    end
    def overlay(element)
        case element.downcase
        when "axis"
            navigate_dropdown(@id,100,40,100,90)
        end
    end
end

## Files window
class Files < Window
    def initialize(id)
        # The Files window is special - it will size itself according to the files in the pwd.
        # Resize it here so the button placement is predictable.
        @default = [400,400]
        super
    end
    def close
        click_on(@id,30,360)
        super
    end
    def pin
        click_on(@id,220,360)
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

# Return the window id from a X window name
# We only return the last element from xdotool
def get_window_id(search_string)
    (xdotool "search --name '#{search_string}'").split("\n")[-1]
end

# Move the mouse relative to the window id to (x,y) and click
def click_on(id,x,y)
    # Get the position of this window id
    position = get_position(id)
    # Add the [x,y] passed in by get_position to our x and y
    x += position[0]
    y += position[1]
    # Move the mouse to (x,y), then click
    xdotool "mousemove #{x} #{y}"
    xdotool "click 1"
    sleep $sleep_time
end

# Select an option from a dropdown menu in a window id
# (x1,y1) represent the position of the menu button, (x2,y2) the option to be selected
def navigate_dropdown(id,x1,y1,x2,y2)
    # Get the position of this window id
    position = get_position(id)
    # Add the [x,y] passed in by position to x1, y1, x2, y2
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

# Return the (x,y) position of the top-left corner of an X window
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
