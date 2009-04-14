# -*- coding: utf-8 -*-
require 'flickr'
require 'highline/import'
HighLine.track_eof = false

module Filetter

  def self.open_brawser(url)
    case RUBY_PLATFORM
    when /linux/
      system 'firefox', url
    when /mswin(?!ce)|mingw|bccwin/
      system 'explorer', url
    else
      system 'open', url
    end
  end

  flickr_api_key = '83f3811287387fa8c604bf3bdcec2c9f'
  flickr_secret = '7c180f792cf64ca9'
  flickr = Flickr.new('./flickr_token', flickr_api_key, flickr_secret)

  unless flickr.auth.token
    puts 'Please allow to access to your Flickr account.'
    open_brawser flickr.auth.login_link('write')

    a = ask("Did you have allowed? [Y/n] ") {|q| q.validate = /^(y|yes|n|no)$/i }
    case a
    when /^y/i
      flickr.auth.getToken
      flickr.auth.cache_token
    when /^n/i
      puts 'No token for Flickr authentication!'
      exit!
    end
  end

  Dir.mkdir('done') unless File.exist?('done')

  config.flickr.set_default(:title, nil)
  config.flickr.set_default(:description, nil)
  config.flickr.set_default(:tags, nil)
  config.flickr.set_default(:public, false)
  config.flickr.set_default(:friend, false)
  config.flickr.set_default(:family, false)

  add_hook :create do |files, event|
    files.each do |file|
      if File.file?(file) && Pathname.new(file).dirname == Pathname.pwd
        Thread.start do
          puts "=> Upload '#{file}' to flickr."
          flickr.photos.upload.upload_file(
            file,
            config.flickr.title,
            config.flickr.description,
            config.flickr.tags,
            config.flickr.public,
            config.flickr.friend,
            config.flickr.family
          )
          rename_to = 'done/' + File.basename(file)
          File.rename(file, rename_to)
        end
      end
    end
  end
end
