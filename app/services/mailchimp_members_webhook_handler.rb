class MailchimpMembersWebhookHandler

  def initialize(data)

    @data=data

    @type=data[:type]
    @timestamp=data[:fired_at]

    @list_id=data[:data][:list_id]
    @user_uuid=data[:merges].to_h[:UUID]

  end

  def list
    @list||=Newsletter::List.find_by_id(@list_id)
  end

  def process
    case @type
      when "unsubscribe"
        producer=GorgService::Producer.new()

        email=@data[:data][:email]
        uuid=@data[:data][:merges].to_h['UUID']
        reason=@data[:data][:reason]

        message=GorgService::Message.new(
                                             data:{
                                                 list_id: @list_id,
                                                 user_uuid: uuid,
                                                 user_email: email,
                                                 timestamp: @timestamp,
                                                 reason:  reason
                                             },
                                             event: "event.newsletter.member.unsubscribed",
                                             soa_version: "2.0",
        )

        producer.publish_message(message)
      else
        puts @data
        nil
    end

  end

end