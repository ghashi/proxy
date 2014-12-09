class GetIp
  def self.call
    last_ip = (`tail config/ip`).scan(/\d+/)
    new_ip = "#{last_ip[0]}.#{last_ip[1]}.#{last_ip[2]}.#{Integer(last_ip[3]) + 1}"

    p last_ip

    f = File.open("config/ip", "w")
    f.puts(new_ip)
    f.close

    new_ip
  end
end
