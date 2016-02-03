require 'json'
# require 'byebug'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)

    cookie = req.cookies['_rails_lite_app']
    @contents = ( cookie ? JSON.parse(cookie) : {})
    # debugger
  end

  def [](key)
    @contents[key]
  end

  def []=(key, val)
    @contents[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie('_rails_lite_app', {path: '/', value: @contents.to_json})
  end
end
