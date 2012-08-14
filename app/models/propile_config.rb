class PropileConfig < ActiveRecord::Base
  attr_accessible :description, :name, :value

  def self.is_set (prop_name)
    prop = find_by_name(prop_name) 
    !prop.nil? && prop.value == "true" 
  end
end
