module Itslog
  module BufferedLoggerExtension
    include Itslog::Configure
    extend ActiveSupport::Concern
    attr_accessor :namespace

    def namespace
      @namespace ||= ''
    end

    def add_with_format(severity, message = nil, progname = nil, &block)
      return if @level > severity

      config = Itslog::Configure

      format = config.format.dup
      color  = color(namespace, severity)

      time    = Time.now.to_s(:db).split.last
      message = "\e[37m" + message.to_s.strip

      msg = ''
      msg << color if color.present?
      msg << format
      msg.gsub!("%t", time)
      msg.gsub!("%n", namespace) if namespace.present?
      msg.gsub!("%m", message)

      add_without_format severity, msg, progname, &block
    end

    def color(namespace, severity)
      color_by = Itslog::Configure.color_by
      if color_by == :severity || severity > 1
        Itslog::Configure.severity_colors[severity]
      elsif color_by == :namespace
        Itslog::Configure.namespace_colors[namespace]
      else
        raise 'color_by can only be :severity or :namespace'
      end
    end

    included do
      alias_method_chain :add, :format
    end
  end

  module LogSubscriberExtension
    extend ActiveSupport::Concern

    def call_with_namespace(message, *args)
      namespace = message.split('.').last if logger
      if logger.respond_to?(:namespace=)
        logger.namespace = namespace.present? ? namespace : ''
      end
      call_without_namespace(message, *args)
    end

    included do
      alias_method_chain :call, :namespace
    end
  end
end
