
class Numeric
  #convert degrees to radians
  def to_rads
    self * (Math::PI / 180)
  end

  #convert radians to degrees
  def to_degs
    self * (180 / Math::PI)
  end
    
   #correct for bearing slipping past the 0/360 mark  
  def bearing

    if self > 360
      self - 360
    elsif self < 0
      360 + self
    else
      self
    end

  end
    
end

