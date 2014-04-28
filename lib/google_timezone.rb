require 'google_timezone/version'
require 'google_timezone/base'
require 'google_timezone/result'

module GoogleTimezone
  class << self
    def fetch(*args)
      lat, lon = if args.first.is_a? Array
                  args.first
                 else 
                  args[0..1]
                end
      Base.new(args).fetch(lat, lon)
    end

    def fetch!(*args)
      lat, lon = if args.first.is_a? Array
                  args.first
                 else 
                  args[0..1]
                end
      Base.new(args).fetch!(lat, lon)
    end
  end
end
