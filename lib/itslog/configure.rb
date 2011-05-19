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

    def color(namespace, severity)
      if self.color_by == :severity || severity > 1
        self.severity_colors[severity].presence || "\e[37m"
      elsif self.color_by == :namespace
        self.namespace_colors[namespace].presence || "\e[37m"
      else
        raise 'itslog: configuration of color_by can only be :severity or :namespace'
      end
    end
  end
end
