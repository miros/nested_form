module NestedForm
  class Builder < ::ActionView::Helpers::FormBuilder
    def link_to_add(name, association, html_options = {})
      html_options["data-association"] = association
      html_options[:class] = ([html_options[:class]] << "add_nested_fields").compact.join(' ')

      @template.link_to(name, "javascript:void(0)", html_options)
    end

    def button_to_add(name, association, html_options = {})
      html_options["data-association"] = association
      html_options[:class] = ([html_options[:class]] << "add_nested_fields").compact.join(' ')

      html_options[:type] = 'button'
      html_options[:name] = "add_#{association}"
      html_options[:value] = name

      @template.content_tag(:input, '', html_options)
    end

    def link_to_remove(name, html_options = {})
      html_options[:class] = ([html_options[:class]] << "remove_nested_fields").compact.join(' ')
      hidden_field(:_destroy) + @template.link_to(name, "javascript:void(0)", html_options)
    end

    def fields_for_with_nested_attributes(association_name, args, block)
      register_blueprint_generator_callback(association_name, args, block)
      options = args.extract_options!
      options[:association_name] = association_name
      args.push(options)
      super
    end

    def fields_for_nested_model(name, association, options, block)
      wrapper = options[:wrapper_tag] || :div
      @template.content_tag(wrapper, super, :class => 'fields', 'data-association' => options[:association_name], 'data-id' => association.to_param || 'new')
    end

    def register_blueprint_generator_callback(association, args, block)
      model_object = object.class.reflect_on_association(association).klass.new
      options = args.last.is_a?(Hash) ? args.last : {}

      @template.after_nested_form(association) do
        _opts = options.dup.merge(:child_index => "new_#{association}")
        blueprint = fields_for(association, model_object, _opts, &block)
        blueprint = CGI.escapeHTML(blueprint).html_safe
        @template.content_tag(:div, '', :id => "#{association}_fields_blueprint", :style => "display: none", 'data-blueprint' => blueprint)
      end
    end
  end
end
