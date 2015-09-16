# This tool is used to check that certain url's are responding.
# We use to to ensure that our server comes back up correctly 
# after a reboot. For configuration, look at 'url_checker.yml'.


require "net/https"
require "uri"
require 'net/smtp'
require 'YAML'


@have_errors = false


def main()

  urls,cfg = load_configuration()

  log = test_all_urls(urls)

  notify(log, cfg)

end


def load_configuration()
  cfg_file = YAML.load_file('url_checker.yml')
  urls = cfg_file['urls']
  cfg = cfg_file['config']

  return urls, cfg

end


def test_all_urls(urls)

  log = []

  urls.each do |url|
    address = url['address']
    expected_text = url['expected_text']

    uri = URI.parse(address)
    http = Net::HTTP.new(uri.host, uri.port)
  
    if (address.include?("https:"))
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    contains_text = response.body.include?(expected_text)

    if (!contains_text)
      msg = "- #{address}:\n  Failed: Text Not Found: \"#{expected_text}\"."
      @have_errors = true
    else
      msg = "- #{address}:\n  Passed"
    end

    puts msg
    log << msg + "\n"

  end

  return log

end


def notify(log, cfg)

  # Exit Early
  if (cfg['Notify'] == 'OnErrors' && @have_errors == false)
    return
  elsif (cfg['Notify'] == 'Never')
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

