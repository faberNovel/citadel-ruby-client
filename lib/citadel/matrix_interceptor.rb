# frozen_string_literal: true

class MatrixInterceptor
  require 'http'
  require 'json'

  def need_to_wait_and_retry(response)
    wait_time = JSON.parse(response.body)['retry_after_ms']
    if wait_time
      Rails.logger.debug 'Wait for ' + (wait_time / 1000).ceil.to_s + ' seconds'
      sleep((wait_time / 1000).ceil + 1)
      return true
    else
      return false
    end
  end
end
