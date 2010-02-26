module StartsAndEndsByDateHour
  def start_date
    start_time.to_date unless start_time.nil?
  end
  
  def end_date
    end_time.to_date unless end_time.nil?
  end
  
  def start_hour
    start_time.hour unless start_time.nil?
  end
  
  def end_hour
    end_time.hour unless end_time.nil?
  end
end