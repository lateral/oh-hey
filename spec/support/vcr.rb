VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_hosts '127.0.0.1',
                 'lateral.dev',
                 'lateral.127.0.0.1.xip.io',
                 'fonts.googleapis.com',
                 'www.google-analytics.com',
                 'cdn.userreport.com'

  # Hide some env vars
  c.filter_sensitive_data('<DOCUMENT_DB_PW>') { ENV['DOCUMENT_DB_PW'] }
  c.filter_sensitive_data('<DOCUMENT_PARSER_PW>') { ENV['DOCUMENT_PARSER_PW'] }
  c.filter_sensitive_data('<LATERAL_NEWS_KEY>') { ENV['LATERAL_NEWS_KEY'] }
  c.filter_sensitive_data('<PUBLIC_CORPORA_KEY>') { ENV['PUBLIC_CORPORA_KEY'] }
  c.filter_sensitive_data('<DROPBOX_KEY>') { ENV['DROPBOX_KEY'] }
  c.filter_sensitive_data('<DROPBOX_SECRET>') { ENV['DROPBOX_SECRET'] }
  c.filter_sensitive_data('<EVERNOTE_HOST>') { ENV['EVERNOTE_HOST'] }
  c.filter_sensitive_data('<EVERNOTE_KEY>') { ENV['EVERNOTE_KEY'] }
  c.filter_sensitive_data('<EVERNOTE_SECRET>') { ENV['EVERNOTE_SECRET'] }
  c.filter_sensitive_data('<GOOGLE_KEY>') { ENV['GOOGLE_KEY'] }
  c.filter_sensitive_data('<GOOGLE_SECRET>') { ENV['GOOGLE_SECRET'] }
  c.filter_sensitive_data('<MAILGUN_API_KEY>') { ENV['MAILGUN_API_KEY'] }
  c.filter_sensitive_data('<MAILGUN_PW>') { ENV['MAILGUN_PW'] }
  c.filter_sensitive_data('<POCKET_CONSUMER>') { ENV['POCKET_CONSUMER'] }
  c.filter_sensitive_data('<TWITTER_KEY>') { ENV['TWITTER_KEY'] }
  c.filter_sensitive_data('<TWITTER_SECRET>') { ENV['TWITTER_SECRET'] }
  c.filter_sensitive_data('<SLACK_WEBHOOK>') { ENV['SLACK_WEBHOOK'] }

  c.ignore_request { |request| request.uri == "https://#{ENV['TWITTER_KEY']}:#{ENV['TWITTER_SECRET']}@api.twitter.com/oauth2/token" }
end
