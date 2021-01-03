# frozen_string_literal: true
module Quacker
  extend self

  QUACKS = [ "Quack", "Quack.", "Hwain", "Quack quack", "Quack!", "Quack?", "quack", "quack quack quack", "Quack, Quack", "Quack", ].freeze

  def quack
    QUACKS.sample
  end
end
