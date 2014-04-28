require 'json'
require 'open-uri'
require 'timeout'

module GoogleTimezone

  class Error < StandardError; end

  class Base
    @allowed_params = [:language, :sensor, :timestamp, :client, :signature, :key, :timeout]

    def initialize(*args)
      @options = extract_options!(args)
      @options.reject! { |key, value| !@allowed_params.include? key }
    end

    def fetch(lat, lon)
      location = [lat, lon].join(',')
      params = { location: location, sensor: false, timestamp: Time.now.to_i }.merge(@options)
      result = get_result(params)
      Result.new(result)
    end

    def fetch!(lat, lon)
      result = fetch(lat, lon)
      raise(GoogleTimezone::Error.new(result.result)) unless result.success?
      result
    end

    private
    def hash_to_query(hash)
      require 'cgi' unless defined?(CGI) && defined?(CGI.escape)
      hash.collect{ |p|
        p[1].nil? ? nil : p.map{ |i| CGI.escape i.to_s } * '='
      }.compact.sort * '&'
    end

    def url(params)
      "https://maps.googleapis.com/maps/api/timezone/json?#{hash_to_query(params)}"
    end

    def extract_options!(*args)
      args.last.is_a?(::Hash) ? pop : {}
    end

    # @raises Timeout::Error
    def get_result(params)
      timeout = @options[:timeout]
      timeout ||= 10
      Timeout::timeout(timeout) do
        open(url(params)) { |r| JSON.parse(r.read) }
      end
    end
  end
end
