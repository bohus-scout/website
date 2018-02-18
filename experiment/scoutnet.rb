#!/usr/bin/ruby

require 'optparse'
require "net/http"
require "uri"
require "json"
require 'pp'

def MissingArg(id)
    ArgumentError.new("Required argument '#{id}' is missing")
end


$default_url = "https://www.scoutnet.se/api/group/memberlist"

class ScoutnetFetcher
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

class Scoutnet < Hash
    def initialize(fetcher: raise(MissingArg(:fetcher)))
	super 
	@fetcher = fetcher
    end

    def refresh
	self.update(@fetcher.fetch)
	self
    end
    def fetch
	@fetcher.fetch
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

    fetcher = ScoutnetFetcher.new(options)
    scoutnet = Scoutnet.new(fetcher: fetcher)
    scoutnet.refresh
    pp scoutnet
end
