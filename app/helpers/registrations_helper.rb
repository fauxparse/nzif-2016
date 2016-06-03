module RegistrationsHelper
  def registration_step(step, current_step)
    content_tag(:li, class: step_state(step, current_step)) do
      concat(link_to_if(step.complete?, step.description, step_path(step)) {
        content_tag(:span, step.description)
      })
    end
  end

  private

  def step_state(step, current_step)
    (step == current_step) ? :current : step.complete? ? :complete : :pending
  end

  def step_path(step)
    step.complete? &&
      registration_step_path(festival, step) ||
      register_path(festival)
  end
end