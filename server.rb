require "rubygems"
require "em-websocket"
require "json"
require "logger"

module EventMachine
  class Channel
    attr_reader :subs
  end
end

EM.run do
  
  @log = Logger.new("log/websocket.log", "daily")
  @log.datetime_format = "%F %T"
  @channels = Hash.new
  @messages    = 0
  

  EM::PeriodicTimer.new(10) do
    @subscribers = 0
    @channels.each do |path, channel|
      @subscribers += channel.subs.count
    end
    @log.debug "Channels #{@channels.count}, subscribers #{@subscribers}, messages per second #{@messages / 10}."
    @messages    = 0
  end
  
  EM::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |socket|
  
    socket.onopen do

      payload = Hash.new
    
      sid = channel_for_socket(socket).subscribe do |message| 
        socket.send message 
      end
      
      payload[:server] = "#{sid} connected."
      channel_for_socket(socket).push payload.to_json
      socket.onmessage do |data| 
        channel_for_socket(socket).push data
        @messages += channel_for_socket(socket).subs.count
      end

      socket.onclose do
        channel_for_socket(socket).unsubscribe(sid)
        payload[:server] = "#{sid} disconnected."
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