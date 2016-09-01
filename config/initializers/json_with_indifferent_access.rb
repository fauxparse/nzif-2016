module JSONWithIndifferentAccess
  def load(string)
    return new if string.blank?
    load_with_indifferent_access(JSON.load(string))
  end

  def dump(object)
    JSON.dump(object)
  end

  private

  def load_with_indifferent_access(object)
    case object
    when Hash
      object.each.with_object(new) do |(k, v), hash|
        hash[k] = load_with_indifferent_access(v)
      end
    when Array
      object.map(&method(:load_with_indifferent_access))
    else
      object
    end
  end
end

ActiveSupport::HashWithIndifferentAccess.send :extend, JSONWithIndifferentAccess
