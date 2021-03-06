class SendEmailPlugin < Noosfero::Plugin

  def self.plugin_name
    "SendEmailPlugin"
  end

  def self.plugin_description
    _("A plugin that allows sending e-mails via HTML forms.")
  end

  def stylesheet?
    true
  end

  def parse_content(html, source)
    if context.profile
      html.gsub!(/\{sendemail\}/, "/profile/#{context.profile.identifier}/plugin/send_email/deliver")
    else
      html.gsub!(/\{sendemail\}/, '/plugin/send_email/deliver')
    end
    [html, source]
  end

end
