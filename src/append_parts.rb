#!/usr/bin/env ruby

require 'anystyle'
require 'multi_json'
require 'json'
require 'active_record'

file = File.join(File.dirname(__FILE__), "../citations_all.json")
lns = File.readlines(file).join(" ");
json = MultiJson.load(lns);

def extract_parts(x)
  parts = AnyStyle.parse(x)
  parts[0]
end

res = json.map { |e| 
  parsed = extract_parts(e['citation']);
  parsed = parsed.deep_stringify_keys;
  e['parts'] = parsed;
  e
};
path_parts = File.join(File.dirname(__FILE__), "../citations_all_parts.json")
File.open(path_parts, "w") do |f|
  f.write(JSON.pretty_generate(res))
end

# res_titles = json.map { |e| 
#   parsed = extract_parts(e['citation']);
#   parsed = parsed.deep_stringify_keys;
#   begin
#     e['title'] = parsed["title"][0];
#   rescue Exception => f
#     e['title'] = nil;
#   end
#   e
# };
# path_titles = File.join(File.dirname(__FILE__), "../citations_all_just_titles.json")
# File.open(path_titles, "w") do |f|
#   f.write(JSON.pretty_generate(res_titles))
# end


# old code
# res = json.map { |e| extract_parts(e['citation']) };
# # res[0..15].map { |e| e[:title][0]  }

# # stringify keys
# ## deep_stringify_keys from active_record
# res = res.map { |e| e.deep_stringify_keys };

# # combine them
# json.zip(res).each do |x, y|
#   x['parts'] = y
# end
