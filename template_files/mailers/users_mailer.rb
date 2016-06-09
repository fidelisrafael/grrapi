class UsersMailer < ApplicationMailer
  def welcome(user)
    @user = user
    @account_confirmation_url = token_url_for(user, :account_confirmation, user.activation_token)

    mail to: user.email
  end

  def password_recovery(user)
    @user = user

    @password_reset_url = token_url_for(user, :password_update, user.reset_password_token)

    mail to: user.email
  end

  def password_updated(user)
    @user = user

    mail to: user.email
  end

  def activate_account(user)
    @user = user
    @account_confirmation_url = token_url_for(user, :account_confirmation, user.activation_token)
    mail to: user.email
  end

  private
  def token_url_for(user, action, token)
    url_data = {
      site_url: Application::Config.send("#{action}_url_site_url"),
      slug: Application::Config.send("#{action}_url_site_slug"),
      token: token
    }

    Application::Config.send("#{action}_url_format") % url_data
  end
end
