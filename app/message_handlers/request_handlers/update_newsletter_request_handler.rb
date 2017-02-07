require 'gibbon'

class UpdateNewsletterRequestHandler <  GorgService::Consumer::MessageHandler::RequestHandler

  BATCH_SIZE=50000
  SCHEMA={"$schema"=>"http://json-schema.org/draft-04/schema#", "title"=>"Create Google Account message schema", "type"=>"object", "properties"=>{"name"=>{"type"=>"string", "description"=>"Newsletter's name"}, "attributes"=>{"type"=>"object", "description"=>"attributes of users", "additionalProperties"=>false, "patternProperties"=>{"^[A-Z]+$"=>{"type"=>"string", "enum"=>["text", "number", "address", "phone", "date", "url", "imageurl", "radio", "dropdown", "birthday", "zip"]}}, "members"=>{"type"=>"array", "description"=>"UUIDs of group members", "items"=>{"type"=>"object", "properties"=>{"email"=>{"type"=>"string"}, "subscription_status"=>{"type"=>"string", "enum"=>["subscribed", "unsubscribed"]}, "attributes"=>{"type"=>"object"}}}}}}, "additionalProperties"=>true, "required"=>["name", "attributes", "members"]}


  listen_to "request.newsletter.update"

  def validate
    message.validate_data_with(SCHEMA)
  end

  def process
    begin
      gibbon=Gibbon::Request.new(api_key: Application.config[:mailchimp_api_key])

      #Find the newsletter
      list=Newsletter::List.find_by_name(message.data[:name])
      raise_hardfail("NewsletterNotFound") unless list

      #Add necessary attributes
      list.ensure_attributes(message.data[:attributes])

      #Retrieve members list
      current_members=list.members
      target_members=Newsletter::MemberCollection.from_message(message.data[:members],list.id)

      operations=[]
      #Delete missing members
      operations+=(current_members-target_members).select{|m| m.subscription_status != "unsubscribed"}.map(&:remove_operation)

      #Update others
      operations+=target_members.map(&:upsert_operation)

      Application.logger.debug "Operations to send : #{operations.count}"
      #Application.logger.debug "Operations to send : #{operations}"
      batches=[]
      operations.each_slice(BATCH_SIZE) do |ops|
        b=gibbon.batches.create(body: {operations: ops})
        batches<<b
        Application.logger.debug "Submitted batch #{ b.body['id']} (#{b.body["total_operations"].to_s} operations)"
      end

      errors=0
      while batches.any?
        #Wait a bit for Mailchimp to process batches
        sleep 60

        Application.logger.debug "Querying Mailchimp for finished batches"
        batches.reject! do |b|
          resp=gibbon.batches(b.body['id']).retrieve
          if resp.body['status'] == 'finished'
            errors+=resp.body['errored_operations']
            Application.logger.debug "Batch #{b.body['id']} finished !"
            true
          end
        end
      end

      Application.logger.debug "Errors : #{errors}"
    rescue Gibbon::MailChimpError => e
      raise_hardfail("Mailchimp error",error: e)
    end
  end


end