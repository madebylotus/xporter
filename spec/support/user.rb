class User
  attr_accessor :name, :email, :phone

  def initialize(attributes={})
    attributes.each do |key, value|
      public_send("#{ key }=", value)
    end
  end
end
