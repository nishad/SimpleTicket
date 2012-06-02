ActionController::Routing::Routes.draw do |map|
  # Customer default routes
  map.tickets 'tickets', :controller => 'tickets', :action => 'list_open'

  # Admin default routes
  map.admin 'admin', :controller => 'admin/tickets', :action => 'list_pending'

  # Default Routes
  map.connect 'tt/tickets/new', :controller => 'tickets', :action => 'new'
  map.connect '', :controller => 'tickets', :action => 'list_open'
  map.connect ':controller/:action/p/:page'
  map.connect ':controller/:action/:id'
end
