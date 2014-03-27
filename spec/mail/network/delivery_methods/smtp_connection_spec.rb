# encoding: utf-8
require 'spec_helper'

describe "SMTP Delivery Method" do

  before(:each) do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp
    end
  end

  after(:each) do
    Mail.delivery_method.smtp.finish
  end

  it "should send an email using open SMTP connection" do
    mail = Mail.deliver do
      from    'roger@test.lindsaar.net'
      to      'marcel@test.lindsaar.net, bob@test.lindsaar.net'
      subject 'invalid RFC2822'

      smtp_envelope_from 'smtp_from'
      smtp_envelope_to 'smtp_to'
    end

    MockSMTP.deliveries[0][0].should eq mail.encoded
    MockSMTP.deliveries[0][1].should eq 'smtp_from'
    MockSMTP.deliveries[0][2].should eq %w(smtp_to)
  end

  it "should be able to return actual SMTP protocol response" do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp, :port => 587, :return_response => true
    end

    mail = Mail.deliver do
      from    'roger@moore.com'
      to      'marcel@amont.com'
      subject 'invalid RFC2822'
    end

    response = mail.deliver!
    response.should eq 'OK'

  end


  it "should raise an error if no sender is defined" do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp, :port => 587, :return_response => true
    end

    lambda do
      Mail.deliver do
        to "to@somemail.com"
        subject "Email with no sender"
        body "body"
      end
    end.should raise_error('An SMTP From address is required to send a message. Set the message smtp_envelope_from, return_path, sender, or from address.')
  end

  it "should raise an error if no recipient if defined" do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp, :port => 587, :return_response => true
    end

    lambda do
      Mail.deliver do
        from "from@somemail.com"
        subject "Email with no recipient"
        body "body"
      end
    end.should raise_error('An SMTP To address is required to send a message. Set the message smtp_envelope_to, to, cc, or bcc address.')
  end
end
