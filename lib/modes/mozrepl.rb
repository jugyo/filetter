require 'net/telnet'
Filetter.add_hook do |files, event|
  telnet = Net::Telnet.new({
      "Host" => "localhost",
      "Port" => 4242
  }){|c| print c}
  telnet.puts("content.location.reload(true)")
  telnet.close
end
