AzureDirectUpload::Engine.routes.draw do
  post "sign", to: "sas#sign", as: :sas_sign
end
