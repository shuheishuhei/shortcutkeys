Rails.application.routes.draw do
  get '/callback' => 'linebot#callback'
end
