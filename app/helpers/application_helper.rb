# Methods added to this helper will be available to all templates in the application.
require File.join(RAILS_ROOT, '/config/rit_config')

module ApplicationHelper

  def show_admin_content?
    signed_in_as_admin?
  end

  def labeled_field(f, type, key, label=nil, div_klass='', options={})
    label = key.to_s if label.nil?
    div_klasses = div_klass.split + ['fieldset']
    html = '<div class="' + div_klasses.join(' ') + '">'
    html += f.label key.to_sym, label, :class => "infield #{type.to_s}"
    html += f.send type, key.to_sym, options
    html += '</div>'
    html
  end

  def pretty_time(time)
    unless time.nil?

      format = Rit::Config.date_format + " %l%p"
      formatted_time = time.strftime(format).downcase
      formatted_day = time.strftime('%a')
      formatted_zone = time.strftime('%Z')
      '<span class="light">' + formatted_day + '</span> ' + formatted_time + ' <span class="light">' + formatted_zone + '</span>'
    else
      ''
    end
  end

  def select_hour_12(object, method, options={}, html_options={})
    choices = [12] + Array(1..11)
    choices = choices.map { |h| "#{h}AM" } + choices.map { |h| "#{h}PM" }
    choices = choices.zip(Array(0..23))
    select(object, method, choices, options, html_options)
  end

  def date_hour_tags(object, date_method, hour_method, index, label, div_klass='')
    date_val = nil
    date_val = object.instance_eval(date_method).nil? ? nil : object.instance_eval(date_method).strftime(Rit::Config.date_format)
    object_name = object.class.to_s.underscore

    div_klasses = div_klass.split + ['fieldset']
    html = '<div class="' + div_klasses.join(' ') + '">'

    html_id = "#{object_name}_#{index}_#{date_method}"
    html += label_tag html_id, label, :class => 'infield'
    html += text_field_tag "#{object_name}[#{index}][#{date_method}]", date_val, :class => "date", :id => html_id
    html += ' '
    html += select_hour_12 object_name, hour_method, { :include_blank => true }, { :index => index, :class => "hour" }
    html += '</div>'
    html
  end

  def navbar_li(text, path, controller)
    klass = controller_name == controller ? ' class="current"' : ''
    "<li#{klass}>" + link_to(text, path) + "</li>"
  end

  def events_json
    javascript_tag do
      "var all_events = " + Event.all_preview_json
    end
  end
end
