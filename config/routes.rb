Hotel::Application.routes.draw do
  root :to => "home#index"
  resources :product_places
  resources :rsvt_statuses
  resources :rooms
  resources :floors
  resources :shifts
  resources :rate_codes
  resources :room_types
  resources :gst_levels
  resources :gst_types
  resources :rsvt_types
  resources :prpt_grps
  resources :src_gsts
  resources :agents
  resources :nations
  resources :sessions
  resources :users
  resources :rsvt_idvs
  resources :rsvt_grps
  resources :contacts
  resources :walk_ins
  resources :products
  #authen
  match 'user/edit' => 'users#edit', :as => :edit_current_user
  match 'signup' => 'users#new', :as => :signup
  match 'logout' => 'sessions#destroy', :as => :logout
  match 'login' => 'sessions#new', :as => :login
  match 'room_id' => 'rooms#show', :as => :room_id
  #home
  match 'home_edit' => 'home#edit', :as => :home_edit
  match 'home_update' => 'home#update', :as => :home_update
  #report
  match 'rsvt_forecast' => 'reports#rsvt_forecast', :as => :rsvt_forecast  
  match 'gst_his' => 'reports#gst_his', :as => :gst_his
  match 'transaction_report' => 'reports#transaction_report', :as => :transaction_report
  match 'summary_transaction_report' => 'reports#summary_transaction_report', :as => :summary_transaction_report
  match 'guest_in_house' => 'reports#guest_in_house', :as => :guest_in_house
  match 'report_out_standing' => 'reports#report_out_standing', :as => :report_out_standing
  match 'report_trial_balance' => 'reports#report_trial_balance', :as => :report_trial_balance
  match 'report_abf' => 'reports#report_abf', :as => :report_abf
  match 'report_move_room' => 'reports#report_move_room', :as => :report_move_room
  match 'report_check_out' => 'reports#report_check_out', :as => :report_check_out
  
  
  
  
  #reservation
  match 'reservation_index' => 'reservation#reservation_index', :as => :reservation_index
  match 'check_in_index' => 'reception#check_in_index', :as => :check_in_index
  match 'check_in' => 'reception#check_in', :as => :check_in
  match 'check_in_action' => 'reception#check_in_action', :as => :check_in_action
  #cashier
  match 'check_out_index' => 'cashier#check_out_index', :as => :check_out_index
  match 'check_out' => 'cashier#check_out', :as => :check_out
  match 'check_out_room' => 'cashier#check_out_room', :as => :check_out_room
  match 'check_out_payment' => 'cashier#check_out_payment', :as => :check_out_payment
  match 'check_out_folio' => 'cashier#check_out_folio', :as => :check_out_folio
  match 'create_folio' => 'cashier#create_folio', :as => :create_folio
  match 'add_charge' => 'cashier#add_charge', :as => :add_charge
  match 'edit_charge' => 'cashier#edit_charge', :as => :edit_charge
  match 'delete_charge' => 'cashier#delete_charge', :as => :delete_charge
  match 'option_folio' => 'cashier#option_folio', :as => :option_folio
  match 'get_folio' => 'cashier#get_folio', :as => :get_folio
  match 'move_folio' => 'cashier#move_folio', :as => :move_folio
  match 'other_charge' => 'cashier#other_charge', :as => :other_charge
  match 'new_other_charge' => 'cashier#new_other_charge', :as => :new_other_charge
  match 'create_other_charge' => 'cashier#create_other_charge', :as => :create_other_charge
  match 'edit_other_charge' => 'cashier#edit_other_charge', :as => :edit_other_charge
  match 'update_other_charge' => 'cashier#update_other_charge', :as => :update_other_charge
  match 'move_room' => 'cashier#move_room', :as => :move_room
  
  
  #product
  match 'product_id' => 'products#show', :as => :product_id
  match 'product_combo' => 'products#product_combo', :as => :product_combo
  #night audit
  match 'night_audit_action' => 'night_audit#night_audit_action', :as => :night_audit_action

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
