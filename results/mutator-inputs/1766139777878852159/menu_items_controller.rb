class MenuItemsController < ApplicationController
  def link
    str = params[:name]
    node = session[:menu].select(str)
    if node
      redirect_to node.url
    else
      logger.error "(error in menu)"
      redirect_to "/"
    end
  end
end