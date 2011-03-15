var NestedForm = {
  addFieldsHandler: function(eventData, event) {
    // Setup
    var assoc   = $(this).attr('data-association');           // Name of child
    var content = $('#' + assoc + '_fields_blueprint').attr('data-blueprint'); // Fields template

    // Make the context correct by replacing new_<parents> with the generated ID
    // of each of the parent objects
    var context = ($(this).parents('.fields').children('input:first').attr('name') || '').replace(new RegExp('\[[a-z]+\]$'), '');

    // context will be something like this for a brand new form:
    // project[tasks_attributes][1255929127459][assignments_attributes][1255929128105]
    // or for an edit form:
    // project[tasks_attributes][0][assignments_attributes][1]
    if(context) {
      var parent_names = context.match(/[a-z_]+_attributes/g) || [];
      var parent_ids   = context.match(/[0-9]+/g);

      for(i = 0; i < parent_names.length; i++) {
        if(parent_ids[i]) {
          content = content.replace(
            new RegExp('(\\[' + parent_names[i] + '\\])\\[.+?\\]', 'g'),
            '$1[' + parent_ids[i] + ']'
          )
        }
      }
    }

    // Make a unique ID for the new child
    var regexp  = new RegExp('new_' + assoc, 'g');
    var new_id  = new Date().getTime();
    content = content.replace(regexp, new_id);
    content = $(content);

    var appender = $(this).data('fields_appender');
    appender = typeof(appender) == 'function' ? appender : NestedForm.fieldsAppender;
    appender.call(this, content);

    if (typeof($(this).data('success')) == 'function')
    {
      $(this).data('success').call(this, content);
    }

    return false;
  },

  removeFieldsHandler: function(eventData, event) {
    var hidden_field = $(this).prev('input[type=hidden]')[0];
    if (hidden_field) {
      hidden_field.value = '1';
    }
    $(this).closest('.fields').hide();
    return false;
  },

  fieldsAppender: function(content)
  {
    var container = $(this).closest('.nested_fields_container').find('.fields').last();

    if (container.length > 0) {
      container.after(content);
    } else {
      $(this).before(content);
    }
  }
};

$(function() {
  $('form .add_nested_fields').live('click', NestedForm.addFieldsHandler);
  $('form .remove_nested_fields').live('click', NestedForm.removeFieldsHandler);
});