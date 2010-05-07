class EventsController < ApplicationController
  before_filter :authenticate

  def index
    @events = Event.all(:include => :plate_editions)
  end

  def show
    @event = Event.find(params[:id], :include => :plate_editions)
    if @event.nil?
      redirect_to events_url
    else
      @sorted_plate_editions = @event.plate_editions.sort_by { |pe| pe.start_time }
    end
  end
  
  def show_row
    @event = Event.find(params[:id])
    render :partial => 'events/event', :object => @event
  end

  def edit
    @event = Event.find(params[:id])
    
    respond_to do |format|
      format.html { redirect_to events_url }
      format.js
    end
  end

  def create
    @event = Event.new(parse_params)

    respond_to do |format|
      if @event.save
        flash[:notice] = 'Event was successfully created.'
        format.html { redirect_to event_url(@event) }
      else
        @events = Event.all
        format.html  { render :action => :index }
      end
    end
  end

  def update
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html { redirect_to plate_url(@event.plate.id) }
      new_params = parse_params
      if @event.update_attributes(new_params)
        flash[:notice] = 'Event was successfully updated.'
        format.js
      else
        format.js  { render :action => 'edit' }
      end
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(events_url) }
      format.xml  { head :ok }
    end
  end


  private

  def parse_params
    # forms are indexed so we have to pull out the first params hash
    new_params = get_first_indexed_params(:event)
    unless new_params.nil?
      new_params['start_time'] = parse_date_hour(new_params, "start") if new_params.key? 'start_date'
      new_params['end_time'] = parse_date_hour(new_params, "end") if new_params.key? 'end_date'
      new_params
    else
      nil
    end
  end
end
