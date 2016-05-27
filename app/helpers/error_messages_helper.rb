module ErrorMessagesHelper
  def error_messages_for(object, attribute)
    messages = object.errors.full_messages_for(attribute)
    unless messages.empty?
      content_tag(:ul, class: "inline-errors") do
        messages.each do |message|
          concat content_tag(:li, message)
        end
      end
    end
  end

  module FormBuilderAdditions
    def error_messages_for(attribute)
      @template.error_messages_for(@object, attribute)
    end

    def label_text(attribute)
      ActionView::Helpers::Tags::Translator
        .new(object, object_name.to_s, attribute.to_s, scope: "helpers.label")
        .translate || attribute.to_s.humanize
    end
  end
end

ActionView::Helpers::FormBuilder
  .send(:include, ErrorMessagesHelper::FormBuilderAdditions)
