
module Bones::Colors
  extend self

  COLOR_CODES = {
    :clear         =>   0,
    :reset         =>   0,     # synonym for :clear
    :bold          =>   1,
    :dark          =>   2,
    :italic        =>   3,     # not widely implemented
    :underline     =>   4,
    :underscore    =>   4,     # synonym for :underline
    :blink         =>   5,
    :rapid_blink   =>   6,     # not widely implemented
    :negative      =>   7,     # no reverse because of String#reverse
    :concealed     =>   8,
    :strikethrough =>   9,     # not widely implemented
    :black         =>  30,
    :red           =>  31,
    :green         =>  32,
    :yellow        =>  33,
    :blue          =>  34,
    :magenta       =>  35,
    :cyan          =>  36,
    :white         =>  37,
    :on_black      =>  40,
    :on_red        =>  41,
    :on_green      =>  42,
    :on_yellow     =>  43,
    :on_blue       =>  44,
    :on_magenta    =>  45,
    :on_cyan       =>  46,
    :on_white      =>  47
  }

  COLOR_CODES.each { |name,code|
    module_eval <<-CODE
      def #{name.to_s}( str )
        "\e[#{code}m\#{str}\e[0m"
      end
    CODE
  }

  def colorize( str, *args )
    args.each { |name|
      code = COLOR_CODES[name]
      next if code.nil?
      str = "\e[#{code}m#{str}\e[0m"
    }
    str
  end
end  # module Bones::Colors

# EOF
