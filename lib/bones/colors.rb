
module Bones::Colors
  extend self

  COLORS = {
    # Embed in a String to clear all previous ANSI sequences.  This *MUST* be
    # done before the program exits!
    #
    :clear      => "\e[0m",
    :erase_line => "\e[K",
    :erase_char => "\e[P",
    :bold       => "\e[1m",
    :dark       => "\e[2m",
    :underline  => "\e[4m",
    :blink      => "\e[5m",
    :reverse    => "\e[7m",
    :concealed  => "\e[8m",

    # Terminal's foreground ANSI colors
    :black      => "\e[30m",
    :red        => "\e[31m",
    :green      => "\e[32m",
    :yellow     => "\e[33m",
    :blue       => "\e[34m",
    :magenta    => "\e[35m",
    :cyan       => "\e[36m",
    :white      => "\e[37m",

    # Terminal's background ANSI colors
    :on_black   => "\e[40m",
    :on_red     => "\e[41m",
    :on_green   => "\e[42m",
    :on_yellow  => "\e[43m",
    :on_blue    => "\e[44m",
    :on_magenta => "\e[45m",
    :on_cyan    => "\e[46m",
    :on_white   => "\e[47m"
  }
  COLORS[:reset]      = COLORS[:clear]
  COLORS[:underscore] = COLORS[:underline]

  # This method provides easy access to ANSI color sequences, without the user
  # needing to remember to CLEAR at the end of each sequence.  Just pass the
  # _string_ to color, followed by a list of _colors_ you would like it to
  # be affected by.  The _colors_ can be class constants, or symbols (:blue
  # for BLUE, for example).  A CLEAR will automatically be embedded to the
  # end of the returned String.
  #
  # This method returns the original _string_ unchanged if colorize? is
  # +false+.
  #
  def colorize( string, *colors )
    return string unless colorize?

    colors.map! { |c|
      c.is_a?(Symbol) ? COLORS[c] : c
    }
    "#{colors.flatten.join}#{string}#{COLORS[:clear]}"
  end

  # Returns true if Bones is currently using color escapes.
  #
  def colorize?
    Bones.config.colorize
  end

end  # module Bones::Colors

