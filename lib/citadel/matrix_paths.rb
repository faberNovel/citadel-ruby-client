# frozen_string_literal: true

class MatrixPaths

  def base_uri
    ENV['TENANT_URL'] + '/_matrix/client/r0'
  end

  def login_path
    '/login'
  end

  def create_room_path
    '/createRoom'
  end

  def send_message_path(room_id)
    '/rooms/' + room_id + '/send/m.room.message/'
  end

  def invite_in_room_path(room_id)
    '/rooms/' + room_id + '/invite'
  end

  def list_public_rooms_path
    '/publicRooms' + '?limit=' + ENV['PUBLIC_ROOMS_LIMIT']
  end

  def list_joined_rooms_path
    '/joined_rooms'
  end

  def join_room_path(room_id)
    '/rooms/' + room_id + '/join'
  end

  def leave_room_path(room_id)
    '/rooms/' + room_id + '/leave'
  end

  def change_room_visibility_path(room_id)
    '/rooms/' + room_id + '/state/m.room.join_rules'
  end
end
