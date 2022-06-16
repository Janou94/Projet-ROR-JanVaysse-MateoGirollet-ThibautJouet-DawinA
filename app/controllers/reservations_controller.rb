class ReservationsController < ApplicationController
  before_action :set_reservation, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  # GET /reservations or /reservations.json
  def index
    me = current_user
    c = User.find(me.id)
    @reservations = Reservation.all.where(user:c.id)
  end

  # GET /reservations/1 or /reservations/1.json
  def show
  end

  # GET /reservations/new
  def new
    @reservation = Reservation.new
  end

  # GET /reservations/1/edit
  def edit
  end

  # POST /reservations or /reservations.json
  def create
    require 'securerandom'
    ref = SecureRandom.hex
    user = current_user.id
    flight_nb = params.fetch('flight_nb')
    is_business = params.fetch('is_business')
    flight = params.fetch('flight')

    placesBoughtEco = Reservation.all.where(flight:flight).where(is_business:0).sum('flight_nb')
    placesBoughtBusi = Reservation.all.where(flight:flight).where(is_business:1).sum('flight_nb')

    realFlight = Flight.find(flight)

    if (realFlight.departure_date>Date.today && flight_nb.to_i < 100)

      tooMuchTicket = false
      if (is_business.to_i == 1)
        if (flight_nb.to_i + placesBoughtBusi.to_i > realFlight.business_class_seats)
          tooMuchTicket = true
        end
      elsif
        if (flight_nb.to_i + placesBoughtEco.to_i > realFlight.economy_class_seats)
          tooMuchTicket = true
        end
      end

      if (tooMuchTicket == false)
        @reservation = Reservation.create(reference:ref, user:user, flight_nb:flight_nb, is_business:is_business, flight:flight);
        respond_to do |format|
          if @reservation.save
            format.html { redirect_to '/reservations', notice: "Reservation was successfully created." }
            format.json { render :show, status: :created, location: @reservation }
            ReservationMailer.with(user:current_user, reference:ref).send_reservation_mail.deliver_now
          else
            format.html { redirect_to reservation_url(@reservation), notice: "An error has occured" }
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @reservation.errors, status: :unprocessable_entity }
          end
        end
      else
        respond_to do |format|
            format.html { redirect_to flight_url(realFlight), notice: "Not enough plane tickets" }
        end
      end


    else

      respond_to do |format|
        if (realFlight.departure_date<Date.today)
          format.html { redirect_to flight_url(realFlight), notice: "This flight has expired" }
        end
        if (flight_nb.to_i>99)
          format.html { redirect_to flight_url(realFlight), notice: "You can't book more than 99 tickets at once" }
        end
      end
    end



  end

  # PATCH/PUT /reservations/1 or /reservations/1.json
  def update
    respond_to do |format|
      if @reservation.update(reservation_params)
        format.html { redirect_to reservation_url(@reservation), notice: "Reservation was successfully updated." }
        format.json { render :show, status: :ok, location: @reservation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reservations/1 or /reservations/1.json
  def destroy
    @reservation.destroy

    respond_to do |format|
      format.html { redirect_to reservations_url, notice: "Reservation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def reservation_params
      params.require(:reservation).permit(:reference, :user, :flight_nb, :is_business)
    end
end
