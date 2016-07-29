class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :name, :type, :slug, :image, :duration

  def image
    object.image.present? && object.image.url(:medium) || nil
  end

  def type
    object.class.name.demodulize.underscore
  end
end
