class AbstractPlayer < ActiveRecord::Base
  self.abstract_class = true
  self.primary_key = "player_id"

  attr_accessor :value_above_nominal
end