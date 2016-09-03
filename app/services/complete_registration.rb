class CompleteRegistration
  attr_reader :registration

  def initialize(registration)
    @registration = registration
  end

  def call
    return false if registration.complete?
    update_completion_timestamp && send_welcome_email
  end

  private

  def update_completion_timestamp
    registration.update(completed_at: Time.now)
  end

  def send_welcome_email
    Postman
      .registration_confirmation(registration)
      .deliver_later
  end
end
