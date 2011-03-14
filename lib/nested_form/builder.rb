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

    def fields_for_with_nested_attributes(association, args, block)
      @fields ||= {}
      #@fields[association] = block
      @fields[:options] = args.last.is_a?(Hash) ? args.last : {}
      register_blueprint_generator_callback(association, block)
      super
    end

    def fields_for_nested_model(name, association, options, block)
      wrapper = options[:wrapper_tag] || :div
      @template.content_tag(wrapper, super, :class => 'fields')
    end

    def register_blueprint_generator_callback(association, block)
      model_object = object.class.reflect_on_association(association).klass.new
      @template.after_nested_form(association) do
        @template.content_tag(:div, :id => "#{association}_fields_blueprint", :style => "display: none") do
          fields_for(association, model_object, :child_index => "new_#{association}", &block)
        end
      end
    end
  end
end
