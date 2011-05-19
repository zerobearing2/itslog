module Itslog
  module Configure
    extend self
    attr_accessor :format, :namespace_colors, :severity_colors, :color_by

    def color_by
      @color_by ||= :severity
    end

    def format
      @format ||= '%t %n %m'
    end

    def namespace_colors
      @namespace_colors ||= {
        'action_controller' => "\e[32m",
        'active_record'     => "\e[94m",
        'action_view'       => "\e[36m"}
    end

    def severity_colors
      @severity_colors ||= [ "\e[36m","\e[32m","\e[33m","\e[31m","\e[31m","\e[37m"]
    end
  end
end
