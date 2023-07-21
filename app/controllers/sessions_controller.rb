#
# Controller pour faire le login/logout des usagers
#
class SessionsController < ApplicationController
    
  def create

    if id_token = flash[:google_sign_in][:id_token]
      id = GoogleSignIn::Identity.new(id_token)
      user = User.from_courriel(id.email_address)
      if user.nil?
        flash[:notice] = "Accès refusé à #{id.email_address}."
      end
    elsif error = flash[:google_sign_in][:error]
      flash[:notice] = "Accès refusé par Google: #{error}."
    end
      
    if user != nil && user.roles == 'employe'
      e = Employe.find_by_courriel(user.courriel)
      if e.nil? or !e.actif?
        user.destroy
        user = nil
      else
        session[:employe] = e.id
      end
    end
    
    if user.nil?
      redirect_to root_url
      return;
    end

    session[:user] = user.id
    flash[:notice] = "Accès accordé à #{user.courriel} avec le role #{user.roles}."
    if user.roles == 'employe'
      redirect_to auto_url
    else
      redirect_to instructions_url
    end
    
  end

  def destroy
    reset_session
    flash[:notice] = "Logout complété."
    redirect_to root_url
  end
  
end