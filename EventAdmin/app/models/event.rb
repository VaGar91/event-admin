# frozen_string_literal: true

class Event < ApplicationRecord
  
  has_one_attached :image

  attr_accessor :remove_image 

  scope :public_events, -> { where(public: true)}
  scope :private_events, -> { where(public: false)}
  
end
