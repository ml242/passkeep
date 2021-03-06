class EntriesController < ApplicationController

  before_filter :set_entry, only: [:edit, :show, :update, :confirm_destroy,
                                      :destroy]
  before_filter :check_permissions, only: [:edit, :update, :confirm_destroy,
                                              :destroy]

  def index
    @entries = current_user.entries.skinny.order(:search_text)
    count = @entries.count(distinct: true)
    @entries = @entries.paginate(page: params[:page], total_entries: count)
    @tags = current_user.entries.tag_counts_on(:tags).order(:name)
  end

  def new
    @entry = Entry.new
    project_guid = params[:project]
    unless project_guid.blank?
      @entry.project_id = Project.find_by_guid(project_guid).id
    end
  end

  def create
    @entry = Entry.new(params[:entry])
    if @entry.save
      redirect_to project_entry_path(@entry.project, @entry), notice: entry_flash(@entry).html_safe
    else
      render :new
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json {
        @entry.can_edit = current_user.can_edit? @entry.project
        render json: @entry.to_json(include: [:project],
          methods: [:notes, :password, :username, :url, :tags, :can_edit])
      }
    end
  end

  def edit
  end

  def update
    if @entry.update_attributes(params[:entry])
      redirect_to project_entry_path(@entry.project, @entry), notice: entry_flash(@entry).html_safe
    else
      render :edit
    end
  end

  def confirm_destroy
  end

  def destroy
    @entry.destroy
    redirect_to(entries_path, notice: "Awesome. You deleted #{@entry.title}")
  end

  def paginate
    tag_name = params[:tag_name].to_s
    entries = current_user.entries
    entries = entries.tagged_with(tag_name) unless tag_name.blank?
    entries = entries.skinny.order(:search_text).limit(30).offset(params[:idx])
    render json: entries.to_json(methods: [:project_guid, :project_name])
  end

  def tagged
    @tag_name = params[:tag_name].to_s
    @entries = current_user.entries.tagged_with(@tag_name).order(:search_text)
    count = @entries.count(distinct: true)
    @entries = @entries.paginate(page: params[:page], total_entries: count)
    @tags = current_user.entries.tag_counts_on(:tags).order(:name)
    render :index
  end

  private
    def check_permissions
      return redirect_to project_entry_path(@entry.project, @entry) unless current_user.can_edit? @entry.project
    end

    def entry_flash entry
      render_to_string partial: "flash", locals: { entry: entry }
    end

    def set_entry
      @entry = Entry.find_by_guid!(params[:id])
    end

end
