require 'pubnub'

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def track_activity(trackable_object)
    activity = current_user.activities.create(action: params[:action], trackable: trackable_object)
    $pubnub.publish(
      channel: 'feed_channel',
      message:  "#{activity.id}"
    ) do |envelope| 
        puts envelope.parsed_response
      end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
    devise_parameter_sanitizer.for(:sign_up) << :avatar
    devise_parameter_sanitizer.for(:account_update) << :name
    devise_parameter_sanitizer.for(:account_update) << :avatar
  end

end