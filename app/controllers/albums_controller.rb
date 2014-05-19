class AlbumsController < ApplicationController
  respond_to :js, :html
  before_action :create_form, except: [:index]

  def index
    @albums = Album.all
  end

  def show
    @album = Album.find(params[:id])
  end

  def create
    execute_album_workflow(:new)
  end

  def update
    execute_album_workflow(:edit)
  end

  private

  def execute_album_workflow(action)
    if @form.validate(params[:album])
      respond_with(store(@form.sync.model))
    else
      render(action)
    end
  end

  def store(album)
    ActiveRecord::Base.transaction do
      album.songs.each { |song| song.user = save_user(song.user) }
      album.save
      album
    end
  end

  def save_user(song_user)
    if song_user.id && User.exists?(song_user.id)
      song_user.save # update existing user
      return song_user
    end

    matching_user = User.find_by(first_name: song_user.first_name, last_name: song_user.last_name)
    return matching_user if matching_user # return matching user

    song_user.save # create new user
    song_user
  end

  def album
    @album ||= album_from_params
  end
  helper_method :album

  def album_from_params
    album = Album.find(params[:id]) if params[:id]
    album || Album.new
  end

  def create_form
    @form = Forms::AlbumForm.new(album)
  end
end
