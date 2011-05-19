module Itslog
  module Configure
    extend self
    attr_accessor :format

    def format
      @format ||= '%t %n %m'
    end
  end
end

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

      colors  = ["\e[36m","\e[32m","\e[33m","\e[31m","\e[31m","\e[37m"]
      time    = Time.now.to_s(:db).split.last
      message = colors[5] + message.to_s.strip

      msg = colors[severity] << Itslog::Configure.format.dup
      msg.gsub!("%t", time)
      msg.gsub!("%n", namespace) if namespace.present?
      msg.gsub!("%m", message)

      add_without_format \
        severity, msg, progname, &block
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
