class UsersController < ApplicationController
  def paginate_list(users)
    paginate_options = {"1" => 25, "2" => 50, "3" => 100}

    # If the above hash does not have a value for the key,
    # it means that we need to show all the users on the page
    #
    # Just a point to remember, when we use pagination, the
    # 'users' variable should be an object, not an array

    # The type of condition for the search depends on what the user has selected from the search_by dropdown
    @search_by = params[:search_by]

    # search for corresponding users
    # users = User.search_users(role, user_id, letter, @search_by)

    # paginate
    users = if paginate_options[@per_page.to_s].nil? # displaying all - no pagination
              users.paginate(page: params[:page], per_page: users.count)
            else # some pagination is active - use the per_page
              users.page(params[:page]).per_page(paginate_options[@per_page.to_s])
            end
    users
  end
end
