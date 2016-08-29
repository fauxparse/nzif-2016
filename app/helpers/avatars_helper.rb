module AvatarsHelper
  def avatar(participant, options = {})
    content_tag(:div, class: :avatar) do
      if participant.avatar.present?
        concat image_tag(participant.avatar.url(options[:size] || :small))
      else
        concat inline_svg("icons/face")
      end

      concat content_tag(:span, participant.name, rel: :name)
    end
  end
end
