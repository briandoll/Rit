class PlateSetsController < ApplicationController
  before_filter :authenticate, :only => [ :index, :show, :show_row, :generate_plates ]
  before_filter :authenticate_admin, :only => [ :new, :create, :edit, :update, :destroy, :create_plate ]

  def index
    @plate_sets = PlateSet.all
    @plate_set = nil
  end

  def show
    @plate_set = PlateSet.find(params[:id])
    if @plate_set.nil?
      redirect_to plates_url
    end
  end

  # xhr
  def show_row
    @plate_set = PlateSet.find(params[:id])
    render :partial => 'plate_set', :object => @plate_set
  end

  # xhr
  def edit
    @plate_set = PlateSet.find(params[:id])

    respond_to do |format|
      format.html { redirect_to plate_sets_url }
      format.js
    end
  end

  # xhr post, html response
  def create
    @plate_set = PlateSet.new(get_first_indexed_params(:plate_set))

    respond_to do |format|
      if @plate_set.save
        flash[:notice] = 'PlateSet was successfully created.'
        format.html { redirect_to plate_set_url(@plate_set) }
      else
        # TODO - do an ajax update
        @plate_sets = PlateSet.all
        format.html  { render :action => 'index' }
      end
    end
  end

  # xhr
  def update
    @plate_set = PlateSet.find(params[:id])

    respond_to do |format|
      format.html { redirect_to plate_set_url(@plate_set) }
      if @plate_set.update_attributes(get_first_indexed_params(:plate_set))
        flash[:notice] = 'Plate Set was successfully updated.'
        format.js
      else
        format.js  { render :action => 'edit' }
      end
    end
  end

  def destroy
    @plate_set = PlateSet.find(params[:id])
    @plate_set.destroy

    respond_to do |format|
      format.html { redirect_to(plate_sets_url) }
    end
  end

  def create_plate
    @plate_set = PlateSet.find(params[:id])
    @plate_set_plate = PlateSetPlate.new(get_first_indexed_params(:plate_set_plate))
    @plate_set_plate.plate_set = @plate_set

    respond_to do |format|
      if @plate_set_plate.save
        flash[:notice] = 'Plate was successfully created.'
        format.html { redirect_to plate_set_url(@plate_set) }
      else
        @plate_set_plates = @plate_set.plate_set_plates
        format.html  { render :action => 'show' }
      end
    end
  end

  def generate_plates
    @plate_set = PlateSet.find(params[:id])

    if @plate_set.nil? or params[:instance_name].blank?
      redirect_to plate_sets_url
    else
      @plate_set.plate_set_plates.each do |set_plate|
        plate = Plate.new( :layout_name   => @plate_set.layout_name,
                           :instance_name => params[:instance_name],
                           :plate_name    => set_plate.plate_name,
                           :description   => set_plate.description )
        plate.save
      end
      redirect_to plates_url(:fl => @plate_set.layout_name, :fi => params[:instance_name])
    end
  end
end
