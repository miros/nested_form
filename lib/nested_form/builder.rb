module NestedForm
  class Builder < ::ActionView::Helpers::FormBuilder
    def link_to_add(name, association, html_options = {})
      @fields ||= {}
      @template.after_nested_form(association) do
        model_object = object.class.reflect_on_association(association).klass.new
        output = %Q[<div id="#{association}_fields_blueprint" style="display: none">].html_safe
        output << fields_for(association, model_object, :child_index => "new_#{association}", &@fields[association])
        output.safe_concat('</div>')
        output
      end

      html_options["data-association"] = association
      html_options[:class] = ([html_options[:class]] << "add_nested_fields").compact.join(' ')

      @template.link_to(name, "javascript:void(0)", html_options)
    end

    def link_to_remove(name, html_options = {})
      html_options[:class] = ([html_options[:class]] << "remove_nested_fields").compact.join(' ') 
      hidden_field(:_destroy) + @template.link_to(name, "javascript:void(0)", html_options)
    end

    def fields_for_with_nested_attributes(association, args, block)
      @fields ||= {}
      @fields[association] = block
      super
    end

    def fields_for_nested_model(name, association, args, block)
      output = '<div class="fields">'.html_safe
      output << super
      output.safe_concat('</div>')
      output
    end
  end
end
