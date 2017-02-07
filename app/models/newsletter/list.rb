require 'gibbon'

module Newsletter
  class List

    attr_accessor :id
    attr_accessor :name

    def initialize(opts={})
      self.id=opts.fetch(:id, nil)
      self.name=opts.fetch(:name, nil)
    end

    def members
      MemberCollection.retrieve_for_list(self.id)
    end

    def ensure_attributes(attrs)

      Application.logger.debug "Ensure existence of attributes : #{attrs.to_s}"

      gibbon=Gibbon::Request.new(api_key: Application.config[:mailchimp_api_key])
      currents=gibbon.lists(id).merge_fields.retrieve.body['merge_fields'].map{|m|m['tag']}

      Application.logger.debug "Current attributes : #{currents.to_s}"

      to_add=attrs.reject{|k,v|currents.include?(k.to_s.upcase)}

      to_add.each do |k,v|
        Application.logger.debug "Create attribute #{k.to_s.upcase} (#{v.to_s})"
        gibbon.lists(id).merge_fields.create(body:{
            name: k.to_s.upcase,
            tag: k.to_s.upcase,
            type: v,
        })
      end
    end

    def self.from_mailchimp(hash)
      self.new(
          id: hash["id"],
          name: hash["name"],
      )
    end

    def self.find_by_name(name)
      gibbon=Gibbon::Request.new(api_key: Application.config[:mailchimp_api_key])
      lists=gibbon.lists.retrieve.body['lists']
      raw_list=lists.find { |l| l['name'].to_s.downcase==name.to_s.downcase }
      raw_list&&from_mailchimp(raw_list)
    end
  end
end