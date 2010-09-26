module EventsHelper
  def event_klasses(event)
    klasses = ["with-icon"]
    if event.live?
      klasses << "lightning-icon"
    else
      if event.publish
        klasses << "check-icon"
      else
        klasses << "cross-icon"
      end
    end
    klasses.join(' ')
  end

  def link_to_event_edit(event)
    options = { :url => edit_event_url(event), :method => :get }
    if event.live?
      options[:confirm] = "This is a LIVE event.  Are you sure you want to edit?"
    end
    link_to_remote("Edit", options)
  end
end
