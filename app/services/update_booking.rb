class UpdateBooking
  include Cry

  def initialize(selection, params)
    @selection = selection
    @params = sanitize(params)
  end

  def call
    if selection.update(@params)
      publish(:success, selection)
    else
      publish(:failure, selection)
    end
  end

  private

  attr_reader :selection, :params

  def sanitize(params)
    params.require(:selection).permit(:schedule_id)
  end
end
