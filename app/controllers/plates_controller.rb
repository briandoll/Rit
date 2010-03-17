class PlatesController < ApplicationController
  before_filter :authenticate, :only => [ :index, :show, :show_row, :create_plate_edition ]
  before_filter :authenticate_admin, :only => [ :new, :create, :edit, :update, :destroy ]

  def index
    conditions = []
    args = []
    append_filter(conditions, args, 'layout_name', params[:fl])
    append_filter(conditions, args, 'instance_name', params[:fi])
    append_filter(conditions, args, 'plate_name', params[:fp])
    conditions = conditions.join(' AND ')
    unless params[:fl].blank? and params[:fi].blank? and params[:fp].blank?
      @filtering = [params[:fl], params[:fi], params[:fp]].map { |f| f == PlatesHelper::FILTER_ALL ? '' : f }.join(":")
    else
      @filtering = ''
    end
    @plates = Plate.find(:all, :include => [ :plate_editions, :default_plate_edition ],
                         :conditions => [conditions, *args]).sort_by { |plate| "#{plate.layout_name}-#{plate.instance_name}-#{plate.plate_name}" } 
    
  end

  def show
    @plate_edition = nil
    @plate = Plate.find(params[:id], :include => [ { :plate_editions => :plate }, :default_plate_edition ])
    if @plate.nil?
      redirect_to plates_url
    else
      if @plate.plate_editions.count > 0 and @plate.default_plate_edition.nil?
        @notices = [ "This plate has no fallback edition"]
      end
      @live_edition = @plate.edition_now
      @sorted_editions = @plate.plate_editions.sort_by { |pe| pe.start_time.nil? ? Plate::BEGINNING_OF_TIME : pe.start_time }
    end
  end
  
  def show_row
    @plate = Plate.find(params[:id])
    render :partial => 'plate', :object => @plate
  end

  # TODO - check for nil plate
  def create
    @plate = Plate.new(params[:plate].first[1])
    if @plate.save
      flash[:notice] = 'Plate created'
      redirect_to plates_url
    else
      @plates = Plate.find(:all)
      render :action => 'index'
    end
  end
  
  def create_plate_edition
    @plate = Plate.find(params[:id])
    @plate_edition = PlateEdition.new(parse_params)
    @plate_edition.plate = @plate

    respond_to do |format|
      if @plate_edition.save
        flash[:notice] = 'PlateEdition was successfully created.'
        format.html { redirect_to plate_url(@plate) }
      else
        format.html  { render :action => 'show' }
      end
    end
  end
  
  # TODO - check for nil plate
  def edit
    @plate = Plate.find(params[:id])
    respond_to do |format|
      format.html do
        render :template => 'plates/edit'
      end
      format.js
    end
  end

  # TODO - check for nil plate
  def update
    @plate = Plate.find(params[:id])
    saved = @plate.update_attributes(params[:plate].first[1])
    respond_to do |format|
      if saved
        success_message = 'Plate was successfully updated.'
        format.html do
          flash[:notice] = success_message
          redirect_to plate_url(@plate)
        end
        flash.now[:notice] = success_message
        format.js
      else
        format.html { render :action => 'edit' }
        format.js { render :action => 'edit' }
      end
    end
  end

  def destroy
    @plate = Plate.find(params[:id])
    unless @plate.nil?
      @plate.destroy
      flash[:notice] = 'Plate deleted'
    end
    redirect_to plates_url
  end

  def published
    @plate = Plate.find(:first, :conditions => { :layout_name   => params[:layout_name],
                                                 :instance_name => (params[:instance_name].nil? ? '' : params[:instance_name]),
                                                 :plate_name    => params[:plate_name] })
    respond_to do |format|
      unless @plate.nil?
        if params.has_key?(:date)
          publish_date = Time.zone.at(params[:date].to_i)
          @edition = @plate.edition_on(publish_date)
        else
          # TODO - Ugly solution to loading the class for Marshal in development mode.  Marshal!
          PlateEdition
          Event

          @edition = Rails.cache.read(published_cache_key(@plate))
          if @edition.nil?
            # cache miss
            date = Time.zone.now
            @edition = @plate.edition_on(date)
            unless @edition.nil?
              expire_time = @edition.current_end_time
              opts = {}
              opts = { :expires_in => (expire_time - date).to_i.seconds } unless expire_time.nil?
              # TODO - what if it already expired in the time that we did edition_on and current_end_time?
              Rails.cache.write(published_cache_key(@plate), @edition, opts)
            end
          end
        end
        if @edition.nil?
          # no edition found for this plate
          format.html { render :xml => '', :status => 404 }
        else
          format.html { render :xml => @edition.content }
        end
      else
        format.html { render :xml => '', :status => 404 }
      end
    end
  end

  private
  include ParsesPlateEditionParameters

  def published_cache_key(plate)
    "plate/#{plate.id}/published"
  end
  
  def append_filter(conditions, args, field_name, value)
    unless value.nil? or value == PlatesHelper::FILTER_ALL
      conditions << "#{field_name} = ?"
      args << value
    end
  end
end