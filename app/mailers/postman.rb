class Postman < ApplicationMailer
  add_template_helper(MoneyHelper)

  def registration_confirmation(registration)
    @registration = registration
    @participant = registration.participant
    @festival = registration.festival
    @pending_payments = registration.payments.pending.all

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

  def receipt(payment)
    @payment = payment
    @registration = payment.registration
    @participant = @registration.participant
    @festival = @registration.festival
    @account = Account.new(@registration)

    mail(
      to: @participant.email,
      subject: I18n.t('postman.receipt.subject')
    )
  end

  def incident_report_notification(incident)
    @incident = incident
    @festival = incident.festival

    mail(
      to: User.admin.map(&:email),
      subject: I18n.t('postman.incident_report_notification.subject')
    )
  end
end
