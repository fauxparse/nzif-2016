module RegistrationsHelper
  def registration_step(step, current_step)
    content_tag(:li, class: step_state(step, current_step)) do
      concat(link_to_if(step.complete?, step.description, step_path(step)) {
        content_tag(:span, step.description)
      })
    end
  end

  def registration_checklist_item(name, label, path, &block)
    content_tag :li, data: { done: @checklist.send(:"#{name}?") || nil } do
      link_to(path) {
        concat inline_svg('icons/check-circle-large')
        concat(content_tag(:div) {
          concat content_tag(:h4, label)
          yield if block_given?
        })
      }
    end
  end

  def registration_step_form(&block)
    form_for(registration_form.step, as: :registration, url: register_path(festival), method: :post) do |form|
      concat hidden_field_tag(:step, form.object.id)
      block.call(form)
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
