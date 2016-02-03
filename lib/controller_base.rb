require 'active_support'
require 'active_support/core_ext'
require 'erb'
# require 'byebug'

require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = route_params.merge(req.params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the res status code and header
  def redirect_to(url)
    if already_built_response?
      raise "Already rendered :("
    else
      @already_built_response = true
    end

    @res['location'] = url
    @res.status = 302

    session.store_session(@res)

    nil
  end

  # Populate the res with content.
  # Set the res's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if already_built_response?
      raise "Already rendered :("
    else
      @already_built_response = true
    end

    @res['Content-Type'] = content_type.to_s
    @res.write(content)

    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    path = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    contents = File.read(path)
    template = ERB.new(contents).result(binding)
    render_content(template, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?

    # nil
  end
end

