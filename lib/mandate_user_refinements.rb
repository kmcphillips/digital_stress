# frozen_string_literal: true

module MandateUserRefinements
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def dave
      mandate_user("dave")
    end

    def eliot
      mandate_user("eliot")
    end

    def kevin
      mandate_user("kevin")
    end

    def patrick
      mandate_user("patrick")
    end

    def arturo
      mandate_user("arturo")
    end

    private

    def mandate_user(name)
      from_config(config: User::USERS["mandatemandate"].values.find { |cfg| cfg[:name] == name }, server: "mandatemandate")
    end
  end

  def dave?
    self == self.class.dave
  end

  def eliot?
    self == self.class.eliot
  end

  def kevin?
    self == self.class.kevin
  end

  def patrick?
    self == self.class.patrick
  end

  def mandate_name
    User::USERS.dig("mandatemandate", id, :name)
  end

  def mandate_display_name
    User::USERS.dig("mandatemandate", id, :display_name)
  end
end
