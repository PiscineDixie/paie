class RootController < ApplicationController
  
  # Use the common layout for all controllers
  layout "paie"

  def index
    if session[:user] && !User.exists?(session[:user])
      reset_session
    end
    
    # if login as an employee, redirect to the employee home
    if session[:user] and !User.hasAdminPriviledge(session[:user])
      redirect_to controller: 'auto'
      return
    end
  end
end