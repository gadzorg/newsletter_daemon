require 'json'

module Newsletter
  class Member

    attr_accessor :email
    attr_accessor :subscription_status
    attr_accessor :attributes
    attr_accessor :list_id

    def ==(other)
      self.email == other.email
    end

    alias_method :eql?, :==
    alias_method :===, :==

    def initialize(opts={})
      self.email=opts.fetch(:email, "")
      self.subscription_status=opts.fetch(:subscription_status, "subscribed")
      self.attributes=opts.fetch(:attributes, {})
      self.list_id=opts.fetch(:list_id, "")
    end

    def attributes=(hash)
      if hash
        @attributes=hash.map do |k, v|
          key=k.upcase
          key=case key
                when 'FIRSTNAME', 'FIRST_NAME', 'PRENOM'
                  "FNAME"
                when 'LASTNAME', 'LAST_NAME', 'NOM'
                  'LNAME'
                else
                  key
              end
          [key, v]
        end.to_h
      end
    end

    def mailchimp_subscripter_hash
      #md5Hash of lowercase email
      Digest::MD5.hexdigest(self.email.downcase)
    end

    def to_mailchimp_body
      {
          email_address: self.email,
          status_if_new: self.subscription_status,
          status: self.subscription_status,
          merge_fields: self.attributes
      }.delete_if { |k, v| v.nil? }
    end

    def upsert_operation
      {
          method: "PUT",
          path: "lists/#{list_id}/members/#{mailchimp_subscripter_hash}",
          body: self.to_mailchimp_body.to_json
      }
    end

    def remove_operation

      {
          method: "PUT",
          path: "lists/#{list_id}/members/#{mailchimp_subscripter_hash}",
          body: self.to_mailchimp_body.merge({status: "unsubscribed"}).to_json
      }
    end


    def self.parse_from_mailchimp(hash)
      self.new(
          email: hash["email_address"],
          subscription_status: hash["status"],
          attributes: hash["merge_fields"],
          list_id: hash["list_id"]
      )
    end

    def self.parse_from_message(hash, list_id)
      self.new(
          email: hash["email"],
          subscription_status: hash["subscription_status"],
          attributes: hash["attributes"],
          list_id: list_id
      )
    end


  end
end