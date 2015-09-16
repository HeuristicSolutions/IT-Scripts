#! /usr/bin/ruby

# daemon - Daemon Monitor
# Windows specific monitor for services. If the service 
# is not running it will restart it. 

require 'net/smtp'
require 'win32/service'
require 'YAML' unless defined?(YAML)
include Win32

def main()

  @log = []
  @have_notifications = false

  #options = get_opts(ARGV)
  @cfg, @daemons = load_configuration()

  @daemons.each do |daemon|
    
    begin
      state = Service.status(daemon).current_state
    rescue Exception => e
      #do something with it
      @log << " # Error with service - [#{daemon}]"
      @log << "   #{e}"
      @have_notifications = true
      next
    end

    if state == 'stopped'
      @log << " + Starting service   - [#{daemon}]"
      begin
        Service.start(daemon)
      rescue Exception => e
        @log << "   Error: #{e}"
      end
      @have_notifications = true
    else
      @log << " - Already running    - [#{daemon}]"
    end

  end

  notify(@log, @cfg)
end


def load_configuration()
  cfg_file = YAML.load_file('daemon_cfg.yml')
  daemons = cfg_file['daemons']
  cfg = cfg_file['config']

  return cfg, daemons

end


def notify(log, cfg)

  if (cfg['Notify'] == 'OnErrors' && @have_notifications == false)
    return
  end

  #puts log.join("\n") if cfg['NotifyOnErrors']
  Net::SMTP.start(
   cfg['SmtpServer'],
   cfg['SmtpPort'],
   cfg['SmtpDomain'],
   cfg['SmtpUid'],
   cfg['SmtpPwd'], 
   cfg['SmtpAuthType'].to_sym) do |smtp|

      smtp.send_message(email_body(log, cfg), cfg['EmailFrom'], cfg['EmailTo'])
  end

end


def email_body(log, cfg)

  body = ""
  body << "From: #{cfg['EmailFrom']}\n"
  body << "To: #{cfg['EmailTo'].join(",")}\n"
  body << "Subject: #{cfg['EmailSubject']}\n"
  body << "Mime-Version: 1.0\n"
  body << "\n"
  body << "\n"
  body << log.join("\n")
  body << "\n"
  return body

end

main()

