class Notifications < ActionMailer::Base
 
  FromAddress = "sessions@agileday.it"
  default from: FromAddress
  helper :application

  def account_reset(account)
    @account = account
    mail to: account.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.session_submit.subject
  #
  def session_submit(presenter, session)
    @greeting = "Hi"
    @login_guid = presenter.account.authentication_token
    @session = session
    mail to: presenter.email, :subject => Propile::Application.mail_subject_prefix + I18n.t('notifications.session_submit.subject')
  end

  def review_creation(email, review)
    @review = review
    @session= review.session
    mail to: email, :subject => Propile::Application.mail_subject_prefix + "Review on session '#{review.session.title}'"
  end

  def comment_creation(email, comment)
    @review = comment.review
    @comment = comment
    @session= @review.session
    mail to: email, :subject => Propile::Application.mail_subject_prefix + "Comment for review on session '#{@session.title}'"
  end

  
end
