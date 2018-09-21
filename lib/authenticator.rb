# frozen_string_literal: true

class Authenticator
  require 'http'
  require 'json'
  require 'matrix_paths'

  def get_token(login, password)
    matrix_paths = MatrixPaths.new
    url = matrix_paths.base_uri + matrix_paths.login_path
    data_hash = { type: 'm.login.password', user: login, password: password }
    data = JSON.generate data_hash
    response = HTTP.post(url, body: data)
    JSON.parse(response.body)['access_token']
  end
end
