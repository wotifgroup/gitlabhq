class Admin::GroupsController < Admin::ApplicationController
  before_filter :group, only: [:edit, :show, :update, :destroy, :project_update, :project_teams_update]

  def index
    @groups = Group.order('name ASC')
    @groups = @groups.search(params[:name]) if params[:name].present?
    @groups = @groups.page(params[:page]).per(20)
  end

  def show
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def create
    @group = Group.new(params[:group])
    @group.path = @group.name.dup.parameterize if @group.name
    @group.owner = current_user

    if @group.save
      redirect_to [:admin, @group], notice: 'Group was successfully created.'
    else
      render "new"
    end
  end

  def update
    group_params = params[:group].dup
    owner_id =group_params.delete(:owner_id)

    if owner_id
      @group.change_owner(User.find(owner_id))
    end

    if @group.update_attributes(group_params)
      redirect_to [:admin, @group], notice: 'Group was successfully updated.'
    else
      render "edit"
    end
  end

  def project_teams_update
    @group.add_users(params[:user_ids].split(','), params[:group_access])

    redirect_to [:admin, @group], notice: 'Users were successfully added.'
  end

  def destroy
    @group.destroy

    redirect_to admin_groups_path, notice: 'Group was successfully deleted.'
  end

  private

  def group
    @group = Group.find_by_path(params[:id])
  end
end
