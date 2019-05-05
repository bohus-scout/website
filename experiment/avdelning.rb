#!/usr/bin/ruby

require "./scoutnet.rb"

class Avdelning < Array
    def initialize(name: raise(MissingArg(:name)), scouts: raise(MissingArg(:scoutnet)))
        @@_items = ["email", "contact_alt_email", "contact_email_dad", "contact_guardian_email", "contact_email_mum"]
        @scouts = scouts
        @name = name
        pattern = name.downcase
        super ( 
               @scouts["data"].map{ |_,scout| 
                   if scout["unit"]["value"].downcase.match(pattern)
                       @@mail_items.map{|x| scout[x]["value"] if scout[x]}.compact
                   end
               }.compact.flatten 
        )
 
    end
end

if __FILE__ == $0
    require 'optparse'
    options = {:uri => $default_url }
    parser = OptionParser.new(
	banner: "Usage: #{$0} [--uri <scoutnet-url>] --id <group-id> --auth <authentication token> --group <group> [--",
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
        opts.on("--group GROUP", "Group of people (spårare, upptäckare, ...)") do |group|
            options[:group] = String(group)
        end
	opts.on("-h", "--help", "Print this help") do
	    exit
	end
    end
    parser.parse!

    maillist = MailList.new(
        name: options[:group], 
        scouts: Scoutnet.new(
            fetcher: ScoutnetFetcher.new(options.select{|x| [:uri, :id, :key].include?(x)})
        ).refresh
    )
    puts maillist.join(", ")
 
end


