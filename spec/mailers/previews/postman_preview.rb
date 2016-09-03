# Preview all emails at http://localhost:5000/rails/mailers/postman
class PostmanPreview < ActionMailer::Preview
  def registration_confirmation
    Postman.registration_confirmation(Registration.last)
  end

  def itinerary_email
    Postman.itinerary(Registration.last)
  end

  def receipt_email
    Postman.receipt(Payment.last)
  end
end
