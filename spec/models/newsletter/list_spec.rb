require 'spec_helper'

describe Newsletter::List do

  it "parse mailchimp response" do
    mailchimp_response={
        "id" => "abcde12345",
        "name" => "Some List",
        "contact" => {
            "company" => "Acme Corp",
            "address1" => "157 Nop street",
            "address2" => "",
            "city" => "Somewhere",
            "state" => "",
            "zip" => "84211",
            "country" => "GR",
            "phone" => ""

        },
        "permission_reminder" => "You signed up !",
        "use_archive_bar" => true,
        "campaign_defaults" => {
            "from_name" => "Acme Corp",
            "from_email" => "contact@acme-corp.com",
            "subject" => "",
            "language" => "en"
        },
        "notify_on_subscribe" => "",
        "notify_on_unsubscribe" => "",
        "date_created" => "2016-01-10T10:10:00+00:00",
        "list_rating" => 3,
        "email_type_option" => false,
        "subscribe_url_short" => "http://eepurl.com/a45Kid",
        "subscribe_url_long" => "http://asso.us13.list-manage.com/subscribe?u=abc4567a&id=128748fe63",
        "beamer_address" => "us13-1234657-abcdefed@inbound.mailchimp.com",
        "visibility" => "pub",
        "modules" => [],
        "stats" => {
            "member_count" => 157,
            "unsubscribe_count" => 0,
            "cleaned_count" => 0,
            "member_count_since_send" => 159,
            "unsubscribe_count_since_send" => 0,
            "cleaned_count_since_send" => 0,
            "campaign_count" => 0,
            "campaign_last_sent" => "",
            "merge_field_count" => 2,
            "avg_sub_rate" => 0,
            "avg_unsub_rate" => 0,
            "target_sub_rate" => 0,
            "open_rate" => 0,
            "click_rate" => 0,
            "last_sub_date" => "2016-03-31T08:06:22+00:00",
            "last_unsub_date" => ""
        }
    }
    nl=Newsletter::List.from_mailchimp(mailchimp_response)

    expect(nl.name).to eq("Some List")
    expect(nl.id).to eq("abcde12345")
  end

end