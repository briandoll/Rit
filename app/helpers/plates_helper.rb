module PlatesHelper

  FILTER_ALL = '_all_'

  def filter_select(name, value, type)
    options = Plate.all_cached.map { |plate| [plate.send(type.to_sym), plate.send(type.to_sym)] }.uniq.sort
    options.unshift(["All #{type.humanize.pluralize.downcase}", FILTER_ALL])
    select_tag(name, options_for_select(options, value), { :id => "#{type.dasherize}-filter", :class => 'filter'})
  end
end
