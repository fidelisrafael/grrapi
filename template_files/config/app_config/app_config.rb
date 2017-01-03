require 'figaro'

module Application

  CONFIG = Figaro.env

  module Config

    module_function

    def self.authentication_providers
      JSON.parse(CONFIG.authentication_providers || '[]')
    end

    CONFIG.each_key do |key|
      define_method "#{key}_enabled?" do
        enabled?(key)
      end
    end

    def enabled?(key)
      value = CONFIG.send(key)

      value.eql?('true') || value.eql?(true)
    end

    def disabled?(key)
      !enabled?(key)
    end

    def method_missing(*args)
      CONFIG.send(*args)
    end

  end

  def self.config
    Config
  end
end
