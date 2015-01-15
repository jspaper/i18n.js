#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json'
require 'deep_merge'

# YAML::ENGINE.yamler = 'syck'

src_dir = ARGV[0]
dest_dir = ARGV[1]

def merge_locale(hash, lang, src_dir)
  Dir["#{src_dir}/*.#{lang}.yml"].each do |file_path|
    hash.deep_merge! YAML.load(File.read(File.expand_path('../' + file_path, __FILE__)))[lang]
  end
  return hash
end

def locale(lang = 'default', src_dir)
  locale_default = merge_locale({}, 'default', src_dir)

  if lang != 'default'
    output = Hash.new
    output[lang] = merge_locale(locale_default, lang, src_dir)
    return output
  else
    output = Hash.new
    output[lang] = locale_default
    return output
  end
end

langs = []
Dir["#{src_dir}/*.yml"].each { |file_path|
  matcher = file_path.match(/.*\.(.*)\.yml/)
  langs.push(matcher[1]) if matcher
}.uniq.compact

langs.each do |lang|
  system 'mkdir', '-p', dest_dir
  dest_path = "#{dest_dir}/#{lang}.json"
  File.delete(dest_path) if File.exist?(dest_path)
  File.new(File.expand_path('../' + dest_path, __FILE__), 'w')
  File.write(dest_path, locale(lang, src_dir).to_json)
  p "Saved locale(#{lang}) in #{dest_path} successfully"
end



