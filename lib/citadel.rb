# frozen_string_literal: true

class Citadel
  require 'http'
  require 'json'
  require_relative 'authenticator'
  require_relative 'matrix_paths'
  require_relative 'matrix_interceptor'

  ##############
  # LIST ROOMS #
  ##############

  def self.hi
    puts "hello world"
  end

  def self.init
    ENV['PUBLIC_ROOMS_LIMIT'] = 100
  end

  def self.login(login, password)
    ENV['LOGIN'] = login
    ENV['PASSWORD'] = password
    authenticator = Authenticator.new
    ENV['AUTH_TOKEN']  = 'Bearer ' + authenticator.get_token(login, password)
  end

  def self.list_all_public_rooms
    response = all_public_rooms_response(login, password)
    room_count = JSON.parse(response.body)['total_room_count_estimate'] - 2
    Rails.logger.debug room_count.to_s + ' public rooms'
    room_count = ENV['PUBLIC_ROOMS_LIMIT'].to_i - 1 if ENV['PUBLIC_ROOMS_LIMIT']
    result = []
    (0..room_count).each do
      result << JSON.parse(response.body)['chunk'][i]['room_id']
    end
    result
  end

  def self.list_all_joined_rooms(login, password)
    response = all_joined_rooms_response(login, password)
    rooms = JSON.parse(response.body)['joined_rooms']
    Rails.logger.debug rooms.count.to_s + ' joined rooms'
    rooms
  end

  def all_public_rooms_response(login, password)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.list_public_rooms_path
    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)
    HTTP.auth(auth_token).get(url)
  end

  def all_joined_rooms_response(login, password)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.list_joined_rooms_path
    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)
    HTTP.auth(auth_token).get(url)
  end

  #################
  # ROOM CREATION #
  #################

  def self.create_room
    login = ENV['LOGIN']
    password = ENV['PASSWORD']
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.create_room_path
    randomizer = Random.new
    first_nb = randomizer.rand(100)
    second_nb = randomizer.rand(5000)
    data_hash = { creation_content: { 'm.federate': false },
                  name: 'room lorem ' + first_nb.to_s + ' ' + second_nb.to_s,
                  preset: 'public_chat',
                  visibility: 'public',
                  room_alias_name: 'room_lorem_' + first_nb.to_s + '_' + second_nb.to_s,
                  topic: 'Lorem ipsum quid dolor amet' }
    data = JSON.generate data_hash

    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)

    response = HTTP.auth(auth_token).post(url, body: data)

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(auth_token).post(url, body: data)
    end

    Rails.logger.debug response.body.to_s
    JSON.parse(response.body)['room_id']
  end

  ########
  # SEND #
  ########

  def self.send_message(room_id, message)
    login = ENV['LOGIN']
    password = ENV['PASSWORD']

    matrix_paths = MatrixPaths.new
    randomizer = Random.new
    txn = randomizer.rand(100)
    url = matrix_paths.base_uri + matrix_paths.send_message_path(room_id) + txn.to_s

    data_hash = { msgtype: 'm.text', body: message }
    data = JSON.generate data_hash

    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)

    response = HTTP.auth(auth_token).put(url, body: data)

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(auth_token).put(url, body: data)
    end

    Rails.logger.debug response.body.to_s
  end

  ##########
  # INVITE #
  ##########

  def self.invite_users_in_room(room_id, users_string)
    users = users_string.split(',')
    users.each do |user|
      Rails.logger.debug 'Invite ' + user + ' in ' + room_id
      invite_in_room(room_id, user)
    end
  end

  def self.invite_in_room(room_id, user_id)
    login = ENV['LOGIN']
    password = ENV['PASSWORD']

    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.invite_in_room_path(room_id)
    data_hash = { user_id: user_id }
    data = JSON.generate data_hash

    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)

    response = HTTP.auth(auth_token).post(url, body: data)

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(auth_token).post(url, body: data)
    end

    Rails.logger.debug response.body.to_s
  end

  ###################
  # ROOM MEMBERSHIP #
  ###################

  def self.join_room(room_id, login, password)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.join_room_path(room_id)

    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)

    response = HTTP.auth(auth_token).post(url)
    Rails.logger.debug response.code

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(auth_token).post(url)
      Rails.logger.debug response.code
    end
  end

  def self.leave_room(room_id, login, password)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.leave_room_path(room_id)

    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)

    response = HTTP.auth(auth_token).post(url)
    Rails.logger.debug response.code

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(auth_token).post(url)
      Rails.logger.debug response.code
    end
  end

  ###################
  # ROOM MANAGEMENT #
  ###################

  def self.change_room_visibility(room_id, login, password, visibility)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.change_room_visibility_path(room_id)

    authenticator = Authenticator.new
    auth_token = 'Bearer ' + authenticator.get_token(login, password)

    data_hash = { join_rule: visibility }
    data = JSON.generate data_hash

    response = HTTP.auth(auth_token).put(url, body: data)
    Rails.logger.debug response.code

    matrix_interceptor = MatrixInterceptor.new
    if matrix_interceptor.need_to_wait_and_retry(response)
      Rails.logger.debug 'Retry request'
      response = HTTP.auth(auth_token).put(url)
      Rails.logger.debug response.code
    end
  end
end
