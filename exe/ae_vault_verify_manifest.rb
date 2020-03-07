#!/usr/bin/env ruby

require 'vault'
require 'yaml'

def secret_exists?(value)
  group, secret_key = value.split('/', 2)
  result = Vault.kv(group).list(File.dirname(secret_key))
  result.include?(File.basename(secret_key))
end

def verify(manifest)
  result = []

  manifest.each do |key, value|
    if value.is_a?(Hash)
      result += verify(value)
    else
      result << value unless secret_exists?(value)
    end
  end

  result
end

manifest = YAML.load_file(ARGV[0])
result = verify(manifest)
if result.empty?
  puts "Manifest is verified in #{ENV['VAULT_ADDR']}!"
else
  puts "The following are missing in #{ENV['VAULT_ADDR']}:"
  puts result
  exit 1
end


