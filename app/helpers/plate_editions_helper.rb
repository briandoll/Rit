module PlateEditionsHelper
  def start_time_text(start_time, edition)
    if edition.nil?
      name = '<span class="alert">None scheduled!</span>'
    else
      name = edition.name
    end
    start_time.strftime(Rit::Config.date_format + ' %l %p') + ': ' + name
  end

  def plate_edition_klasses(plate_edition)
    klasses = ["with-icon"]
    if plate_edition.live?
      klasses << "lightning-icon"
    else
      if plate_edition.publish
        klasses << "check-icon"
      else
        klasses << "cross-icon"
      end
    end
    klasses.join(' ')
  end

  def link_to_plate_edition_edit(plate_edition, partial='plate_editions/remote_edit_form')
    options = { :url => edit_plate_edition_url(plate_edition, :partial => partial), :method => :get }
    if plate_edition.live?
      options[:confirm] = "This is a LIVE edition.  Are you sure you want to edit?"
    end
    link_to_remote("Edit", options)
  end

  def times_div_tag(event)
    times_klasses = " event " + event_klasses(event) unless event.nil?
    %Q{<div class="times #{times_klasses}">}
  end

  def edition_update_notice_div(plate_edition, msg)
    %Q{<div id="#{dom_id(plate_edition)}_notice" class="row-flash">#{msg}</div>}
  end
end