require "rubygems"
require "em-websocket"
require "json"

EM.run do
  
  @channels = Hash.new

  #EM::PeriodicTimer.new(10) do
  #  @channels.each do |path, channel|
  #    channel.push  "#{path} The time is now #{Time.now}".to_json
  #  end
  #end
  
  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |socket|
  
    socket.onopen do

      payload = Hash.new
    
      sid = channel_for_socket(socket).subscribe do |message| 
        socket.send message 
      end
      
      puts payload[:server] = "#{sid} connected."
      channel_for_socket(socket).push payload.to_json
      
      socket.onmessage do |data| 
        channel_for_socket(socket).push data
      end

      socket.onclose do
        channel_for_socket(socket).unsubscribe(sid)
        puts payload[:server] = "#{sid} disconnected."
        channel_for_socket(socket).push payload.to_json
      end
    
    end
    
    socket.onerror do |error| 
      puts "Error: #{error.message}" 
    end
    
  end
  
  # Helpers

  def channel_for_socket(socket)
    path = socket.request["Path"].downcase
    @channels[path] ||= EM::Channel.new
  end
  
end