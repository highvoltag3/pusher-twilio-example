require 'rubygems'
require 'sinatra/base'
require 'yaml'

require 'pusher'

require 'builder'

class App < Sinatra::Base

  set :public_folder, Proc.new { File.join(root, "public") }
  
  config = YAML.load_file('./config.yml')
  
  Pusher.app_id = config['pusher']['app_id']
  Pusher.key = config['pusher']['app_key']
  Pusher.secret = config['pusher']['app_secret']
  
  get '/' do
    @app_key = config['pusher']['app_key']
    erb :index
  end

  post '/call' do
    if( params['AccountSid'] != config['twilio']['account_sid'] )
      status 401
    else
      Pusher['calls'].trigger('call_incoming', {
        :from_number =>  '...' + params['From'][-4, 4],
        :timestamp => Time.now.strftime("%Y-%m-%dT%H:%M:%S")  
      })
      
      builder do |xml|
      xml.instruct! :xml, :version => '1.0'
        xml.Response("voice" => "woman") do
          xml.Say "Thanks for Trying my demo. Any questions email darionovoa@ideartte.com"
          xml.Sms("Someone just called the demo", "from" => "+15103986927", "to" => "+14086376002")
        end
      end
    
    end
  end
  
  post '/sms' do
    if( params['AccountSid'] != config['twilio']['account_sid'] )
      status 401
    else
      Pusher['sms'].trigger('sms_received', {
        :from_number => '...' + params['From'][-4, 4],
        :timestamp => Time.now.strftime("%Y-%m-%dT%H:%M:%S"),
        :text => params['Body']
      })
    end
  end
    
  run! if app_file == $0

end