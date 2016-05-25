module RegistrationsHelper
  def registration_step(step)
    classes = [
      (:complete if completed_registration_step?(step)),
      (:active if current_registration_step?(step))
    ].compact
    content_tag :li, t("registrations.steps.#{step}"), class: classes
  end

  private

  def completed_registration_step?(step)
    registration_step_index(step) <
    registration_step_index
  end

  def current_registration_step?(step)
    registration_form.step == step
  end

  def registration_step_index(step = registration_form.step)
    registration_form.steps.index(step)
  end
end
