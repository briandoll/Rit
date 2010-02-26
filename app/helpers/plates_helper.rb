module PlatesHelper
  def filter_select(name, value, type)
    options = Plate.all_cached.map { |plate| [plate.send(type.to_sym), plate.send(type.to_sym)] }.uniq.sort
    options.unshift(["All #{type.humanize.pluralize.downcase}", 'all'])
    select_tag(name, options_for_select(options, value), { :id => "#{type.dasherize}-filter", :class => 'filter'})
  end
end