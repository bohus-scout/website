#!/usr/bin/ruby

require 'optparse'
require "net/http"
require "uri"
require "json"
require 'pp'

module ScoutNet
    def MissingArg(id)
	ArgumentError.new("Required argument '#{id}' is missing")
    end


    $default_url = "https://www.scoutnet.se/api/group/memberlist"

    class Fetcher
	def fetch
	    raise(NotImplementedError)
	end
    end

    class WebFetcher < Fetcher
	class ServerError < Exception
	end

	def initialize( uri: $default_url, id: raise(MissingArg(:id)), key: raise(MissingArg(:key)))
	    @uri = URI(uri)
	    @uri.query = URI.encode_www_form(id: id, key: key)
	end

	def fetch
	    response = Net::HTTP.get_response(@uri)
	    if not response.is_a?(Net::HTTPSuccess)
		raise ServerError.new(response.message)
	    end
	    JSON.parse(response.body)
	end
    end

    class FileFetcher < Fetcher
	def initialize(filename)
	    @filename = filename
	end

	def fetch
	    JSON.load(File.open(@filename))
	end

    end

    class Value < String
	attr_reader :raw
	def initialize( value: raise(MissingArg(:value)), raw_value: nil)
	    super value
	    @raw = raw_value
	end

	def inspect
	    if @raw
		"#{super}:[#{@raw}]"
	    else
		super
	    end
	end
    end


    class Scout
	attr_reader :fields, :id

	def initialize(fields, id, values)
	    @fields = fields.map(&:to_sym)
	    @values = values.
		transform_values{|v| Value.new(**v.transform_keys(&:to_sym))}.
		transform_keys(&:to_sym)
	    @id = id
	end

	def all
	    @values
	end

	def inspect
	    "#<Scout:#{@id}>"
	end

	def method_missing(m, *args, &block)
	    if @values.has_key? m
		@values[m]
	    elsif @fields.member? m
		nil
	    else
		raise ArgumentError.new("Method `#{m}` doesn't exist.")
	    end
	end
    end

    class DB < Array
	attr_reader :labels
	def initialize(fetcher: raise(MissingArg(:fetcher)))
	    super()
	    @fetcher = fetcher
	    @labels = {}
	    self.refresh
	end

	def refresh
	    data = @fetcher.fetch
	    @labels = data["labels"].transform_keys(&:to_sym)
	    keys = @labels.keys
	    self.replace(data["data"].map{|id,scout| Scout.new(keys, id, scout)})
	    self
	end

	def method_missing(m, *args, &block)
	    if @labels.has_key? m
		if args.size == 1
		    self.select{|scout| 
			case scout.send(m)
			    when args[0]
				block.call(scout) if block
				true
			    else
				false
			end
		    }
		else
		    raise ArgumentError.new("wrong number of arguments (given #{args.size}, expected 1)")
		end
	    else
		raise ArgumentError.new("Method `#{m}` doesn't exist.")
	    end
	end


    end
end




if __FILE__ == $0
    require 'optparse'
    options = {:uri => $default_url }
    parser = OptionParser.new(
	banner: "Usage: #{$0} [-uri <scoutnet-url>] -id <group-id> -auth <authentication token>",
    ) do | opts |
	opts.on("--uri URI", "scoutnet url (defaults to #{@default_url})") do |uri|
	    options[:uri] = URI(uri)
	end
	opts.on("--id ID", "Group id") do |id|
	    options[:id] = String(id)
	end
	opts.on("--key KEY", "Authentication key") do |key|
	    options[:key] = String(key)
	end
	opts.on("-h", "--help", "Print this help") do
	    exit
	end
    end
    parser.parse!

    fetcher = ScoutNet::WebFetcher.new(options)
    scoutnet = Scoutnet::DB.new(fetcher: fetcher)
    scoutnet.refresh
    pp scoutnet
end
