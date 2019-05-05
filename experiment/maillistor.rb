#!/usr/bin/ruby

require "pp"
require "./scoutnet.rb"


if __FILE__ == $0
    require 'optparse'
    options = {:uri => $default_url }
    parser = OptionParser.new(
	banner: "Usage: #{$0} [--uri <scoutnet-url>] --id <group-id> --auth <authentication token> --group <group>",
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
        opts.on("--group GROUP", "Group of people") do |group|
            options[:group] = String(group)
        end
	opts.on("-h", "--help", "Print this help") do
	    exit
	end
    end
    parser.parse!

    mail_items = [:email, :contact_alt_email, :contact_email_dad, :contact_guardian_email, :contact_email_mum]
    scouts = ScoutNet::DB.new(
        fetcher: ScoutNet::WebFetcher.new(options.select{|x| [:uri, :id, :key].include?(x)})
    ).refresh

    maillist = scouts.unit(options[:group]).map{|s| mail_items.map{|f| s.send(f)}}
    maillist.flatten!.select!{|s| s}.uniq!

    puts maillist.join(", ")
 
end



