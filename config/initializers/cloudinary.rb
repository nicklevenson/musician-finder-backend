Cloudinary.config do |config|    
   config.cloud_name = Rails.application.credentials.cloudinary[:cloudname]   
   config.api_key = Rails.application.credentials.cloudinary[:key] 
   config.api_secret = Rails.application.credentials.cloudinary[:secret]  
   config.secure = true    
   config.cdn_subdomain = true  
end