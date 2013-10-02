ActionMailer::Base.smtp_settings = {
  :address              => "smtp.gmail.com",
  :port                 => 587,
  :domain               => "sessions.agileday.it",
  :user_name            => "italian.agile.day@gmail.com",
  :password             => ENV["SMTP_PASSWORD"],
  :authentication       => "plain",
  :enable_starttls_auto => true
}
