# frozen_string_literal: true

class MatrixPaths
  require 'http'
  require 'json'

  def base_uri
    ENV['TENANT_URL']
  end

  def login_path
    '_matrix/client/r0/login'
  end

  def create_room_path
    '_matrix/client/r0/createRoom'
  end

  def send_message_path(room_id)
    '_matrix/client/r0/rooms/' + room_id + '/send/m.room.message/'
  end

  def invite_in_room_path(room_id)
    '_matrix/client/r0/rooms/' + room_id + '/invite'
  end

  def list_public_rooms_path
    '_matrix/client/r0/publicRooms' + '?limit=' + ENV['PUBLIC_ROOMS_LIMIT']
  end

  def list_joined_rooms_path
    '_matrix/client/r0/joined_rooms'
  end

  def join_room_path(room_id)
    '_matrix/client/r0/rooms/' + room_id + '/join'
  end

  def leave_room_path(room_id)
    '_matrix/client/r0/rooms/' + room_id + '/leave'
  end

  def change_room_visibility_path(room_id)
    '_matrix/client/r0/rooms/' + room_id + '/state/m.room.join_rules'
  end
end
