require 'grape'
require 'grape-swagger'


class ApplicationAPI < Grape::API
  format :json
  prefix :api


  resource :mailchimp do
    http_basic do |user, password|
      user == ENV['MAILCHIMP_API_USER'] && password == ENV['MAILCHIMP_API_PASSWORD']
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