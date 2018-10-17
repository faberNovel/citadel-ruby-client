# frozen_string_literal: true

require 'http'
require 'json'
require 'citadel/authenticator'
require 'citadel/matrix_paths'
require 'citadel/matrix_interceptor'

module Citadel

  DEFAULT_PUBLIC_ROOMS_LIMIT = 100

  class << self
    attr_accessor :tenant_url, :public_rooms_limit
  end

  class Client
    def initialize(tenant_url, public_rooms_limit = DEFAULT_PUBLIC_ROOMS_LIMIT)
      if tenant_url[-1,1] == '/'
        Citadel.tenant_url = tenant_url[0,tenant_url.length-1]
      else
        Citadel.tenant_url = tenant_url
      end
      Citadel.public_rooms_limit = public_rooms_limit
    end

    #########
    # AUTH #
    #########

    def auth_token
      return @auth_token if defined? @auth_token
      puts 'Citadel: You need to sign in'
      return nil
    end

    def sign_in(login, password)
      authenticator = Authenticator.new
      @auth_token = 'Bearer ' + authenticator.get_token(login, password)
    end

    ##############
    # LIST ROOMS #
    ##############

    def list_all_public_rooms
      response = all_public_rooms_response
      room_count = JSON.parse(response.body)['total_room_count_estimate'] - 2
      result = []
      (0..room_count).each do
        result << JSON.parse(response.body)['chunk'][i]['room_id']
      end
      result
    end

    def list_all_joined_rooms
      response = all_joined_rooms_response
      rooms = JSON.parse(response.body)['joined_rooms']
      rooms
    end

    def all_public_rooms_response
      matrix_paths = MatrixPaths.new
      url = matrix_paths.base_uri + matrix_paths.list_public_rooms_path
      HTTP.auth(auth_token).get(url)
    end

    def all_joined_rooms_response
      matrix_paths = MatrixPaths.new
      url = matrix_paths.base_uri + matrix_paths.list_joined_rooms_path
      HTTP.auth(auth_token).get(url)
    end

    #################
    # ROOM CREATION #
    #################

    def create_room(room_name, topic)
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

      response = HTTP.auth(auth_token).post(url, body: data)

      matrix_interceptor = MatrixInterceptor.new
      if matrix_interceptor.need_to_wait_and_retry(response)
        response = HTTP.auth(auth_token).post(url, body: data)
      end

      JSON.parse(response.body)['room_id']
    end

    ########
    # SEND #
    ########

    def send_message(room_id, message)

      matrix_paths = MatrixPaths.new
      randomizer = Random.new
      txn = randomizer.rand(100)
      url = matrix_paths.base_uri + matrix_paths.send_message_path(room_id) + txn.to_s

      data_hash = { msgtype: 'm.text', body: message }
      data = JSON.generate data_hash

      response = HTTP.auth(auth_token).put(url, body: data)

      matrix_interceptor = MatrixInterceptor.new
      if matrix_interceptor.need_to_wait_and_retry(response)
        response = HTTP.auth(auth_token).put(url, body: data)
      end
    end

    ##########
    # INVITE #
    ##########

    def invite_users_in_room(room_id, users)
      users.each do |user|
        invite_in_room(room_id, user)
      end
    end

    def invite_in_room(room_id, user_id)

      matrix_paths = MatrixPaths.new
      url = matrix_paths.base_uri + matrix_paths.invite_in_room_path(room_id)
      data_hash = { user_id: user_id }
      data = JSON.generate data_hash

      response = HTTP.auth(auth_token).post(url, body: data)

      matrix_interceptor = MatrixInterceptor.new
      if matrix_interceptor.need_to_wait_and_retry(response)
        response = HTTP.auth(auth_token).post(url, body: data)
      end
    end

    ###################
    # ROOM MEMBERSHIP #
    ###################

    def join_room(room_id)
      matrix_paths = MatrixPaths.new
      url = matrix_paths.base_uri + matrix_paths.join_room_path(room_id)

      response = HTTP.auth(auth_token).post(url)

      matrix_interceptor = MatrixInterceptor.new
      if matrix_interceptor.need_to_wait_and_retry(response)
        response = HTTP.auth(auth_token).post(url)
      end
    end

    def leave_room(room_id)
      matrix_paths = MatrixPaths.new
      url = matrix_paths.base_uri + matrix_paths.leave_room_path(room_id)

      response = HTTP.auth(auth_token).post(url)

      matrix_interceptor = MatrixInterceptor.new
      if matrix_interceptor.need_to_wait_and_retry(response)
        response = HTTP.auth(auth_token).post(url)
      end
    end

    ###################
    # ROOM MANAGEMENT #
    ###################

    def change_room_visibility(room_id, visibility)
      matrix_paths = MatrixPaths.new
      url = matrix_paths.base_uri + matrix_paths.change_room_visibility_path(room_id)

      data_hash = { join_rule: visibility }
      data = JSON.generate data_hash

      response = HTTP.auth(auth_token).put(url, body: data)

      matrix_interceptor = MatrixInterceptor.new
      if matrix_interceptor.need_to_wait_and_retry(response)
        response = HTTP.auth(auth_token).put(url)
      end
    end
  end
end
