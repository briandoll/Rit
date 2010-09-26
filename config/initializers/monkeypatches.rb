module QuantizeTime
  def quantized_to_hour
    self.change(:min => 0, :sec => 0)
  end
end

class Time
  include QuantizeTime
end

class DateTime
  include QuantizeTime
end
