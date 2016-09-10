module FaqHelper
  def organizer_image(name)
    participant = Participant.find_by(name: name)
    avatar = participant.try(:avatar)
    image_tag avatar.url(:medium) if avatar.present?
  end
end
