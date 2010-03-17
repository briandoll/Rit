class PlateSetPlatesController < ApplicationController
  before_filter :authenticate, :only => [ :index, :show ]
  before_filter :authenticate_admin, :only => [ :create, :edit, :update, :destroy ]

  def index
    @plate_set = PlateSet.find(params[:plate_set_id])
    @plate_set_plates = @plate_set.plate_set_plates

    respond_to do |format|
      format.html { redirect_to plate_set_url(@plate_set) }
      format.js { render :partial => 'plate_set_plates', :object => @plate_set_plates }
    end
  end

  def show
    @plate_set_plate = PlateSetPlate.find(params[:id])

    respond_to do |format|
      if @plate_set_plate.nil?
          redirect_to plate_sets_url
      else
        format.html { redirect_to plate_set_url(@plate_set_plate.plate_set) }
        format.js { render :partial => 'plate_set_plate', :object => @plate_set_plate }
      end
    end
  end

  def create
    @plate_set_plate = PlateSetPlate.new(get_first_indexed_params(:plate_set_plate))
    @plate_set = PlateSet.find(params[:plate_set_id])
    @plate_set_plate.plate_set = @plate_set
    respond_to do |format|
      if @plate_set_plate.save
        flash[:notice] = 'Plate was successfully created.'
        format.html { redirect_to plate_set_url(@plate_set) }
      else
        # TODO - do an ajax update
        @plate_set_plates = @plate_set.plate_set_plates
        format.html  { redirect_to plate_set_url(@plate_set) }
      end
    end
  end

  def edit
    @plate_set_plate = PlateSetPlate.find(params[:id])

    respond_to do |format|
      format.html { redirect_to plate_sets_url }
      format.js
    end
  end

  def update
    @plate_set_plate = PlateSetPlate.find(params[:id])

    respond_to do |format|
      format.html { redirect_to plate_set_url(@plate_set_plate.plate_set) }
      if @plate_set_plate.update_attributes(get_first_indexed_params(:plate_set_plate))
        flash[:notice] = 'Plate was successfully updated.'
        format.js
      else
        format.js  { render :action => 'edit' }
      end
    end
  end

  def destroy
    @plate_set_plate = PlateSetPlate.find(params[:id])
    @plate_set_plate.destroy

    respond_to do |format|
      format.html { redirect_to plate_set_url(@plate_set_plate.plate_set) }
    end
  end

end
