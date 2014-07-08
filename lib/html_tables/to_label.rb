# encoding: utf-8

module ToLabel
  # override this method on subclasses as needed
  def to_label(*args)
    [:name, :code, :nome, :codigo].each do |m|
      return public_send(m) if respond_to?(m)
    end
    to_s
  end
end

ActiveRecord::Base.send(:include, ToLabel) if defined? ActiveRecord::Base

class NilClass
  def to_label(*args)
    nil
  end
end
