# frozen_string_literal: true

require 'csv'

# class EventAdminController
class EventAdminController < ApplicationController
  def index
    @events = Event.where(user_id: current_user.id).page(params[:page]).per(8)

    if params[:public_events].present? && params[:private_events].present?
      @events = Event.where(user_id: current_user.id).page(params[:page]).per(8)
    elsif params[:public_events].present?
      @events = @events.public_events
    elsif params[:private_events].present?
      @events = @events.private_events
    else
      params[:public_events] = '1' 
      params[:private_events] = '1'
      @events = Event.where(user_id: current_user.id).page(params[:page]).per(8)
    end

    if params[:specific_date].present?
      specific_date = Date.parse(params[:specific_date])
      @events = Event.where(user_id: current_user.id).where(init_date: specific_date).page(params[:page]).per(8)
    elsif params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      if start_date > end_date
        @error_message = "Start date cannot be greater than end date."
        render :index and return
      else
        @events = Event.where(user_id: current_user.id).where(init_date: start_date..end_date).page(params[:page]).per(8)
      end
    elsif (params[:start_date].present? && !params[:end_date].present?) ||
      (params[:end_date].present? && !params[:start_date].present?)
      @error_message = "You must choose a valid date."
      render :index and return
    end
  end

  def public_events
    @events = Event.where(public: true).page(params[:page]).per(8)
    if params[:specific_date].present?
      specific_date = Date.parse(params[:specific_date])
      @events = Event.where(public: true).where(init_date: specific_date)
    elsif params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      if start_date > end_date
        @error_message = "Start date cannot be greater than end date."
        render :public_events and return
      else
        @events = Event.where(public: true).where(init_date: start_date..end_date)
      end
    elsif (params[:start_date].present? && !params[:end_date].present?) ||
      (params[:end_date].present? && !params[:start_date].present?)
      @error_message = "You must choose a valid date."
      render :public_events and return
    end
  end

  def new
    @event = Event.new
  end

  def edit
    @event = Event.find(params[:id])
  end

  def create
    @event = Event.new(event_params)

    if @event.save
      redirect_to events_path, notice: 'Registered Event'
    else
      render :new
    end
  end

  def update
    @event = Event.find(params[:id])

     # Eliminar la imagen adjunta
    @event.image.purge if params.dig(:event, :remove_image).present? && @event.image.attached?
    
    if @event.update(event_params)
      redirect_to events_path, notice: 'Updated event'
    else
      render :edit
    end
  end

  def destroy
    @event = event_find

    if @event.destroy
      redirect_to events_path, notice: 'Deleted event'
    else
      redirect_to events_path, notice: 'Error'
    end
  end

  def delete_image
    @event = Event.find(params[:id])
    @event.image.purge # Elimina la imagen adjunta
    redirect_to edit_event_path(@event), notice: 'Image deleted'
  end

  def export
    @events = Event.where(user_id: current_user.id)

    # Apply filtering based on the search parameters
    if params[:public_events].present?
      @events = @events.where(public: true)
    end

    if params[:private_events].present?
      @events = @events.where(public: false)
    end

    if params[:public_events].present? && params[:private_events].present?
      @events = Event.where(user_id: current_user.id)
    end

    if params[:specific_date].present?
      specific_date = Date.parse(params[:specific_date])
      @events = @events.where(init_date: specific_date)
    end

    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      @events = @events.where(init_date: start_date..end_date.next_day)
    end

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(headers: true) do |csv|
          csv << %w[Title Description Init_Date Cost Location Public]
          @events.each do |event|
            csv << [event.title, event.description, event.init_date, event.cost, event.location, event.public]
          end
        end

        send_data csv_data, filename: "events.csv"
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :init_date, :cost, :location, :image, :public).merge(user_id: current_user.id)
  end

  def event_find
    @event = Event.find(params[:id])
  end

  def permitted_params
    params.permit(:public_events, :private_events, :specific_date, :start_date, :end_date, :format)
  end
end
