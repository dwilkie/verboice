# Copyright (C) 2010-2012, InSTEDD
#
# This file is part of Verboice.
#
# Verboice is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Verboice is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Verboice.  If not, see <http://www.gnu.org/licenses/>.

class BrokerFacade < MagicObjectProtocol::Server
  PORT = Rails.configuration.verboice_configuration[:broker_port].to_i

  def notify_call_queued(channel_id, not_before = nil)
    unless not_before
      channel = Channel.find channel_id
      channel.broker.instance.notify_call_queued channel
    end
    nil
  end

  def create_channel(channel_id, broker_name)
    broker_name.constantize.instance.create_channel channel_id
  end

  def update_channel(channel_id, broker_name)
    broker_name.constantize.instance.update_channel channel_id
  end

  def destroy_channel(channel_id, broker_name)
    broker_name.constantize.instance.destroy_channel channel_id
  end

  def active_calls_count_for(channel_id)
    channel = Channel.find channel_id
    channel.broker.instance.active_calls_count_for channel
  end

  def redirect(session_id, options)
    # TODO: don't know which broker to use
    # BaseBroker.instance.redirect session_id, options
  end

  def channel_status(*channel_ids)
    Asterisk::Broker.instance.channel_status *channel_ids
  end
end
