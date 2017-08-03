VCR.configure do |c|
  puts 'vcr'
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
end
