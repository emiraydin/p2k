class Delivery < ActiveRecord::Base
  belongs_to :user

  enum frequency: [:daily, :weekly]
  enum day: [:Sunday, :Monday, :Tuesday, :Wednesday, :Thursday, :Friday, :Saturday, :Everyday]
  enum option: [:latest, :timed, :random]
    	
end
