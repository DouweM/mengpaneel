require "mengpaneel/version"
require "mengpaneel/engine"
require "mengpaneel/controller"

module Mengpaneel
  mattr_accessor :token
  
  def self.configure(&block)
    yield(self)
  end
end