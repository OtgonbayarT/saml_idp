# encoding: utf-8

module SamlIdp
  class IdpController < ActionController::Base
    include SamlIdp::Controller

    unloadable unless Rails::VERSION::MAJOR >= 4
    protect_from_forgery

    if Rails::VERSION::MAJOR >= 4
      before_action :validate_saml_request, only: [:new, :create, :logout]
    else
      before_filter :validate_saml_request, only: [:new, :create, :logout]
    end

    def new
      render template: "user/login", :layout => false
    end

    def show
      render xml: SamlIdp.metadata.signed
    end

    def create
      unless params[:email].blank? && params[:password].blank?
        person = idp_authenticate(params[:email], params[:password])
        if person.nil?
          @saml_idp_fail_msg = "Incorrect email or password."
        else
          @saml_response = idp_make_saml_response(person)
	  puts "ACS_URL"
          puts saml_acs_url
          render :template => "saml_idp/idp/saml_post", :layout => false
          return
        end
      end
      render :template => "user/login"
    end

    def logout
      idp_logout
      @saml_response = idp_make_saml_response(nil)
      puts "LOGOUT_URL"
      puts saml_logout_url
      render :template => "saml_idp/idp/saml_post_logout", :layout => false
    end

    def idp_logout
      raise NotImplementedError
    end
    private :idp_logout

    def idp_authenticate(email, password)
      raise NotImplementedError
    end
    protected :idp_authenticate

    def idp_make_saml_response(person)
      raise NotImplementedError
    end
    protected :idp_make_saml_response
  end
end
