module ParsesPlateEditionParameters
  def parse_params
    # forms are indexed so we have to pull out the first params hash
    new_params = get_first_indexed_params(:plate_edition)
    unless new_params.nil?
      if new_params['event_id'].blank?
        new_params['start_time'] = parse_date_hour(new_params, "start") if new_params.key? 'start_date'
        new_params['end_time'] = parse_date_hour(new_params, "end") if new_params.key? 'end_date'
      else
        new_params.delete('start_date')
        new_params.delete('start_hour')
        new_params.delete('end_date')
        new_params.delete('end_hour')
      end
      new_params
    else
      nil
    end
  end
end