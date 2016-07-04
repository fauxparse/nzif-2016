class ParticipantSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :avatar

  def avatar
    object.avatar.presence && object.avatar.url(:small)
  end
end
