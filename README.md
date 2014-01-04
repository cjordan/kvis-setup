# kvis-setup

### Prerequisites
Download `kvis-definitions.rb` and one of or both the profile scripts `kvis-wide.rb` and `kvis-square.rb`, placing them somewhere in your `$PATH`. Note that each profile script assumes the definitions file is in the same directory. You will need [xdotool](http://www.semicomplete.com/projects/xdotool/xdotool.xhtml) and [xwininfo](http://linux.die.net/man/1/xwininfo) installed locally, as well as a [Ruby](https://www.ruby-lang.org/en/) interpreter.

### Usage
To set up kvis according to a profile, simply run that script. By default, these profile scripts will open kvis before adjusting. To see a list of available options, simply pass a `-h` flag.

Here are some examples of usage:

+ `kvis-wide.rb` - open kvis, then layout in a "wide" configuration
+ `kvis-wide.rb -h` - help
+ `kvis-wide.rb -d` - see each command passed to xdotool for debugging
+ `kvis-wide.rb -n` - do not open kvis with the script, but layout an open kvis anyway
+ `kvis-wide.rb -s1` - use 1 second buffers between actions; may be useful for slow computers and networks

### Modification
The idea behind having profile scripts is that it's easy to layout kvis in any way you like. Simply use one of my profiles as a template, and modify the order to your liking.

If you require other options to be set that I have not made available in the definitions file, simply add them into the relevant class. Coordinates are determined by screenshots, and I have a small collection for use [here](https://www.dropbox.com/sh/mxn86dhuk34hvet/VuC_AqEQDz).

### Feedback
Please use this GitHub page as a means for discussing any issues you may have. I only use kvis on Linux systems, so Mac testing is difficult.
