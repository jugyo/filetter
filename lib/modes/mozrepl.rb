require 'net/telnet'

config.mozrepl.set_default(:host, 'localhost')
config.mozrepl.set_default(:port, 4242)
config.mozrepl.set_default(:commands, ['content.location.reload(true)'])

Filetter.add_hook do |files, event|
  telnet = Net::Telnet.new( "Host" => config.mozrepl.host,
                            "Port" => config.mozrepl.port ) {|c| print c }
  begin
    config.mozrepl.commands.each do |cmd|
      puts "> #{cmd}"
      telnet.puts(cmd)
    end
  ensure
    telnet.close
  end
end
