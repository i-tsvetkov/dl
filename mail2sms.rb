require 'net/smtp'

def mail2sms(user, pass, phone, msg)
  smtp = Net::SMTP.new('smtp.gmail.com', 587)
  smtp.enable_starttls
  smtp.start('gmail.com', "#{user}@gmail.com", pass, :login)
  smtp.send_message(msg, "#{user}@gmail.com", "#{phone}@sms.mtel.net")
  smtp.finish
end

