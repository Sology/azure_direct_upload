require "singleton"

module AzureDirectUpload
  class Config
    include Singleton

    ATTRIBUTES = []

    attr_accessor *ATTRIBUTES
  end

  def self.config
    if block_given?
      yield Config.instance
    end
    Config.instance
  end
end
