require 'test_helper'

class DialCommandTest < ActiveSupport::TestCase
  setup do
    BaseBroker.instance = mock('broker')
  end

  test "run" do
    dial = DialCommand.new :number => '1234'
    session = Session.new :channel => Channel.make

    BaseBroker.instance.expects(:get_dial_address).with(session.channel, '1234').returns('SIP/1234')
    session.call_log = CallLog.make
    session.pbx = mock('pbx')
    session.pbx.expects(:dial).with('SIP/1234')
    dial.run session
  end
end