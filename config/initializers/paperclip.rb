Paperclip::Attachment.default_options[:s3_host_name] = "s3-#{ENV.fetch('AWS_REGION')}.amazonaws.com"
