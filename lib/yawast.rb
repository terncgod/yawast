# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path + '/**/', '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

require 'uri'
require 'resolv'
require 'net/http'
require 'socket'
require 'colorize'

require File.dirname(__FILE__) + '/string_ext'
require File.dirname(__FILE__) + '/uri_ext'
require File.dirname(__FILE__) + '/util'
require File.dirname(__FILE__) + '/version'

require_all '/commands'
require_all '/scanner'
require_all '/shared'

module Yawast
  DESCRIPTION = 'The YAWAST Antecedent Web Application Security Toolkit'
  HTTP_UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_1) AppleWebKit/537.36 (KHTML, like Gecko) Yawast/#{VERSION} Chrome/56.0.2924.28 Safari/537.36"

  def self.header
    puts '__   _____  _    _  ___   _____ _____ '
    puts '\ \ / / _ \| |  | |/ _ \ /  ___|_   _|'
    puts ' \ V / /_\ \ |  | / /_\ \\\ `--.  | |  '
    puts '  \ /|  _  | |/\| |  _  | `--. \ | |  '
    puts '  | || | | \  /\  / | | |/\__/ / | |  '
    puts '  \_/\_| |_/\/  \/\_| |_/\____/  \_/  '
    puts ''
    puts "YAWAST v#{VERSION} - #{DESCRIPTION}"
    puts ' Copyright (c) 2013-2017 Adam Caudill <adam@adamcaudill.com>'
    puts ' Support & Documentation: https://github.com/adamcaudill/yawast'
    puts " Ruby #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}; #{OpenSSL::OPENSSL_VERSION} (#{RUBY_PLATFORM})"

    begin
      version = JSON.parse(Net::HTTP.get(URI('https://rubygems.org/api/v1/versions/yawast/latest.json')))['version']

      if version != VERSION
        puts " Latest Version: YAWAST v#{version} is the officially supported version, please update.".blue
      end
    rescue
      #we don't care, this is a best effort check
    end

    puts ''
  end

  def self.set_openssl_options
    #change certain defaults, to make things work better
    #we prefer RSA, to avoid issues with small DH keys
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] = 'RSA:ALL:COMPLEMENTOFALL'
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:verify_mode] = OpenSSL::SSL::VERIFY_NONE
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:options] = OpenSSL::SSL::OP_ALL
  end

  STDOUT.sync = true

  trap 'SIGINT' do
    puts
    puts 'Scan cancelled by user.'
    exit 0
  end
end
