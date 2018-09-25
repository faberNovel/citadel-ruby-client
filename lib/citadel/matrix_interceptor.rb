# frozen_string_literal: true

class MatrixInterceptor

  def need_to_wait_and_retry(response)
    wait_time = JSON.parse(response.body)['retry_after_ms']
    if wait_time
      sleep((wait_time / 1000).ceil + 1)
      return true
    else
      return false
    end
  end
end
