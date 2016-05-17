class ParticipantMailer < ApplicationMailer
  def registration_email(registration)
    @registration = registration
    @participant = registration.participant
    @festival = registration.festival

    mail(
      to: @participant.email,
      subject: I18n.t('emails.registration.subject', festival: @festival.name)
    )
  end
end
