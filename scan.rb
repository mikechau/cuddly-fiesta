#!/usr/bin/env ruby

require 'capybara'
require 'capybara/dsl'
require 'fast_blank'
require 'uri'

Capybara.configure do |config|
  config.run_server = false
end

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.default_driver = :selenium_chrome

class Scanner
  include Capybara::DSL

  def self.run(**args)
    scanner = new

    scanner.run(**args)
  end

  def run(ips_list_path:)
    fail('IPS LIST PATH REQUIRED.') if ips_list_path.blank_as?


    IO.foreach(ips_list_path).with_index do |line, idx|
      next if line.blank_as?

      uri = URI.parse(line.chomp)

      puts "[#{idx}] Checking Site: #{uri}"

      visit(uri)
 
      screenshot_path = "#{__dir__}/screenshots/#{uri.host}_#{uri.port}.png"

      save_screenshot(screenshot_path)

      puts "[#{idx}] Saving Screenshot: #{uri} to #{screenshot_path}"
    end
  end
end

Scanner.run(ips_list_path: (ARGV[0] || ''))

