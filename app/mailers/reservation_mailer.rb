class ReservationMailer < ApplicationMailer
  default from: "from@example.com"

  def send_reservation_mail
    @user = params[:user]
    @ref = params[:reference]

    mail(to: @user.email, subject:'Booking confirmation')
  end
end
