module AvatarsHelper
  def avatar(participant, options = {})
    content_tag(:div, class: :avatar) do
      if participant.avatar.present?
        concat image_tag(participant.avatar.url(options[:size] || :small))
      else
        concat inline_svg("icons/face")
      end

      if options[:link]
        concat avatar_email_link(participant)
      else
        concat content_tag(:span, participant.name, rel: :name)
      end
    end
  end

  def avatar_email_link(participant)
    mail_to participant.email do
      concat content_tag(:span, participant.name)
      concat content_tag(:small, participant.email)
    end
  end
end
