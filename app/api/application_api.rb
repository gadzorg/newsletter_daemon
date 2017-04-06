require 'grape'
require 'grape-swagger'


class ApplicationAPI < Grape::API
  format :json
  prefix :api


  resource :mailchimp do
    http_basic do |user, password|
      user == Application.config['mailchimp_api_user'] && password == Application.config['mailchimp_api_password']
    end

    # desc 'Return subscription status of given user '
    get 'susbcription_webhook' do
      {status: "ok"}
    end

    post 'susbcription_webhook' do
      MailchimpMembersWebhookHandler.new(params).process
    end

  end

  add_swagger_documentation mount_path: '/doc'

end