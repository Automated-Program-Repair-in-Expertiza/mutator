class TreeDisplayController < ApplicationController
  def list
    redirect_to controller: :student_task, action: :list if current_user.student?
    # if params[:commit] == 'Search'
    #   search_node_root = {'Q' => 1, 'C' => 2, 'A' => 3}

    #   if params[:search_string]
    #     search_node = params[:searchnode]
    #     session[:root] = search_node_root[search_node]
    #     search_string = params[:search_string]
    #   else
    #     search_string = nil
    #   end
    # else
    #   search_string = nil
    # end

    # search_string = filter if params[:commit] == 'Filter'
    # search_string = nil if params[:commit] == 'Reset'

    # @search = search_string

    # display = params[:display] #|| session[:display]
    # if display
    #   @sortvar = display[:sortvar]
    #   @sortorder = display[:sortorder]
    # end

    # @sortvar ||= 'created_at'
    # @sortorder ||= 'desc'

    # if session[:root]
    #   @root_node = Node.find(session[:root])
    #   @child_nodes = @root_node.get_children(@sortvar,@sortorder,session[:user].id,@show,nil,@search)
    # else
    # child_nodes = FolderNode.get()
    # end
    # @reactjsParams = {}
    # @reactjsParams[:nodeType] = 'FolderNode'
    # @reactjsParams[:child_nodes] = child_nodes
  end
end
