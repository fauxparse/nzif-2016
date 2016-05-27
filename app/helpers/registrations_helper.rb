module RegistrationsHelper
  def registration_step(step, current_step)
    content_tag :li, step.name,
      class: (current_step == step) ? :current : step.state
  end
end
