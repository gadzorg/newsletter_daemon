module Newsletter
  class MemberCollection

    include Enumerable

    RETRIEVE_BATCH_SIZE=5000

    attr_accessor :members


    def each(&block)
      @members.each(&block)
    end

    def +(other)
      self.class.new(self.members+other.members)
    end

    def -(other)
      self.class.new(self.members.reject{|a| other.members.include?(a)})
    end

    def uniq
      self.class.new(self.members.uniq)
    end

    def initialize(m=[])
      self.members=m
    end

    def self.from_mailchimp(arr)
      self.new(arr.map{|h| Member.parse_from_mailchimp(h)})
    end

    def self.from_message(arr,list_id)
      self.new(arr.map{|h| Member.parse_from_message(h,list_id)})
    end


    def self.retrieve_for_list(list_id)
      gibbon=Gibbon::Request.new(api_key: Application.config[:mailchimp_api_key])

      member_count_target=nil
      m_=[]
      i=0

      Application.logger.debug "Start retrieving members for list #{list_id}"
      while !member_count_target || m_.count < member_count_target


        Application.logger.debug "Batch n°#{i} : #{(m_.count+1).to_s} - #{(m_.count+RETRIEVE_BATCH_SIZE).to_s}"

        resp=gibbon.lists(list_id).members.retrieve(params: {fields: "total_items,members.email_address,members.status,members.merge_fields,members.list_id","count": RETRIEVE_BATCH_SIZE.to_s, "offset": m_.count.to_s})
        member_count_target=resp.body["total_items"]

        m_ += resp.body["members"]

        i+=1
      end

      self.from_mailchimp(m_)
    end
  end
end