# frozen_string_literal: true

class Citadel
  require 'http'
  require 'json'
  require 'citadel/authenticator'
  require 'citadel/matrix_paths'
  require 'citadel/matrix_interceptor'

  ##############
  # LIST ROOMS #
  ##############

  def self.login(login, password)
    authenticator = Authenticator.new
    ENV['AUTH_TOKEN']  = 'Bearer ' + authenticator.get_token(login, password)
  end

  def self.list_all_public_rooms
    response = all_public_rooms_response
    room_count = JSON.parse(response.body)['total_room_count_estimate'] - 2
    Rails.logger.debug room_count.to_s + ' public rooms'
    result = []
    (0..room_count).each do
      result << JSON.parse(response.body)['chunk'][i]['room_id']
    end
    result
  end

  def self.list_all_joined_rooms
    response = all_joined_rooms_response
    rooms = JSON.parse(response.body)['joined_rooms']
    Rails.logger.debug rooms.count.to_s + ' joined rooms'
    rooms
  end

  def all_public_rooms_response
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.list_public_rooms_path
    HTTP.auth(ENV['AUTH_TOKEN']).get(url)
  end

  def all_joined_rooms_response
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.list_joined_rooms_path
    HTTP.auth(ENV['AUTH_TOKEN']).get(url)
  end

  #################
  # ROOM CREATION #
  #################

  def self.create_room(room_name, topic)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.create_room_path
    room_name_alias = room_name.gsub!(' ','_')
    data_hash = { creation_content: { 'm.federate': false },
                  name: room_name,
                  preset: 'public_chat',
                  visibility: 'public',
                  room_alias_name: room_name_alias,
                  topic: topic}
    data = JSON.generate data_hash

    response = HTTP.auth(ENV['AUTH_TOKEN']).post(url, body: data)

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(ENV['AUTH_TOKEN']).post(url, body: data)
    end

    Rails.logger.debug response.body.to_s
    JSON.parse(response.body)['room_id']
  end

  ########
  # SEND #
  ########

  def self.send_message(room_id, message)

    matrix_paths = MatrixPaths.new
    randomizer = Random.new
    txn = randomizer.rand(100)
    url = matrix_paths.base_uri + matrix_paths.send_message_path(room_id) + txn.to_s

    data_hash = { msgtype: 'm.text', body: message }
    data = JSON.generate data_hash

    response = HTTP.auth(ENV['AUTH_TOKEN']).put(url, body: data)

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(ENV['AUTH_TOKEN']).put(url, body: data)
    end

    Rails.logger.debug response.body.to_s
  end

  ##########
  # INVITE #
  ##########

  def self.invite_users_in_room(room_id, users)
    users.each do |user|
      Rails.logger.debug 'Invite ' + user + ' in ' + room_id
      invite_in_room(room_id, user)
    end
  end

  def self.invite_in_room(room_id, user_id)

    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.invite_in_room_path(room_id)
    data_hash = { user_id: user_id }
    data = JSON.generate data_hash

    response = HTTP.auth(ENV['AUTH_TOKEN']).post(url, body: data)

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(ENV['AUTH_TOKEN']).post(url, body: data)
    end

    Rails.logger.debug response.body.to_s
  end

  ###################
  # ROOM MEMBERSHIP #
  ###################

  def self.join_room(room_id)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.join_room_path(room_id)

    response = HTTP.auth(ENV['AUTH_TOKEN']).post(url)
    Rails.logger.debug response.code

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(ENV['AUTH_TOKEN']).post(url)
      Rails.logger.debug response.code
    end
  end

  def self.leave_room(room_id)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.leave_room_path(room_id)

    response = HTTP.auth(ENV['AUTH_TOKEN']).post(url)
    Rails.logger.debug response.code

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(ENV['AUTH_TOKEN']).post(url)
      Rails.logger.debug response.code
    end
  end

  ###################
  # ROOM MANAGEMENT #
  ###################

  def self.change_room_visibility(room_id, visibility)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.change_room_visibility_path(room_id)

    data_hash = { join_rule: visibility }
    data = JSON.generate data_hash

    response = HTTP.auth(ENV['AUTH_TOKEN']).put(url, body: data)
    Rails.logger.debug response.code

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(ENV['AUTH_TOKEN']).put(url)
      Rails.logger.debug response.code
    end
  end
end
