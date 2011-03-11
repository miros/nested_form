module NestedForm
  class Builder < ::ActionView::Helpers::FormBuilder
    def link_to_add(name, association, html_options = {})
      @fields ||= {}

      model_object = object.class.reflect_on_association(association).klass.new
      options = @fields[:options].merge(:child_index => "new_#{association}")

      html_options["data-fields"] = CGI.escapeHTML(fields_for(association, model_object, options, &@fields[association]))
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
      @fields[:options] = args.last.is_a?(Hash) ? args.last : {}
      super
    end

    def fields_for_nested_model(name, association, options, block)
      wrapper = options[:wrapper_tag] || :div
      @template.content_tag(wrapper, super, :class => 'fields')
    end
  end
end
