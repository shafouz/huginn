class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  # skip_before_action :verify_authenticity_token

  # before_action :upgrade_warning, only: :index

  def index
    sign_in(User.first)
  end

  def about
  end
end
