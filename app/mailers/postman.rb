class Postman < ApplicationMailer
  def registration_confirmation(registration)
    @registration = registration
    @participant = registration.participant
    @festival = registration.festival

    mail(
      to: @participant.email,
      subject: I18n.t('postman.registration_confirmation.subject', festival: @festival.name)
    )
  end

  def itinerary(registration)
    @registration = registration
    @participant = registration.participant
    @festival = registration.festival
    @itinerary = Itinerary.new(@registration)

    mail(
      to: @participant.email,
      subject: I18n.t('postman.itinerary.subject', festival: @festival.name)
    )
  end
end