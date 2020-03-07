#!/usr/bin/env ruby

require 'vault'
require 'yaml'
require 'json'

def read_secret(value)
  group, secret_key = value.split('/', 2)
  Vault.kv(group).read(secret_key).data[:value]
end

def resolve(manifest)
  result = {}

  manifest.each do |key, value|
    if value.is_a?(Hash)
      result[key] = resolve(value)
    else
      result[key] = read_secret(value)
    end
  end

  result
end

manifest = YAML.load_file(ARGV[0])
puts resolve(manifest).to_json



