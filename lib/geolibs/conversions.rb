#convert degrees to radians
class Numeric
  def degrees
    self * Math::PI / 180 
  end

  def rads
    self * 180 / Math::PI
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

