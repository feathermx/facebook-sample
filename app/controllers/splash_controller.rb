class SplashController < ApplicationController

  before_filter :auth_token
  before_filter :with_session, only: [:friends, :friend]

  def index
    redirect_to action: :friends unless self.auth_token.nil?
  end

  def login
    url = self.oauth.url_for_oauth_code(permissions: 'user_friends,user_photos')
    redirect_to url
  end

  def callback_url
    code = params[:code]
    token = self.oauth.get_access_token(code)
    self.auth_token = token
    redirect_to action: :friends
  end

  def friends
    @friends = self.graph.get_object("me/taggable_friends")
  end

  def photos
    @photos = self.graph.get_object("me/photos")
  end

  def logout
    self.auth_token = nil
    redirect_to action: :index
  end

  protected

  def with_session
    redirect_to action: :index if self.auth_token.nil?
  end

  def auth_token
    @auth_token ||= session[:auth_token]
  end

  def auth_token=(val)
    @auth_token = session[:auth_token] = val
  end

  def oauth
    @oauth ||= ->{
      app_id = '402069926623829'
      app_secret = 'be6d12eb874d5c841008a02448de7f6a'
      callback_url = url_for(action: :callback_url, only_path: false)
      Koala::Facebook::OAuth.new(app_id, app_secret, callback_url)
    }.call
  end

  def graph
    @graph ||= Koala::Facebook::API.new(self.auth_token)
  end


end
