require 'aws-sdk-s3'  # AWS SDK for S3 operations
require 'pry'  # Interactive shell for debugging
require 'securerandom'  # For generating secure random strings (UUIDs)
require 'optparse'  # For parsing command line options

# Function to create an S3 bucket
def create_bucket(client, bucket_name, region)
  resp = client.create_bucket({
    bucket: bucket_name,  # Name of the bucket
    create_bucket_configuration: {
      location_constraint: region  # Region for the bucket
    }
  })
  puts "Bucket '#{bucket_name}' created successfully in region '#{region}'"
rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
  puts "Bucket '#{bucket_name}' already exists and is owned by you."
rescue Aws::S3::Errors::ServiceError => e
  puts "Failed to create bucket: #{e.message}"
end

# Function to upload a file to an S3 bucket
def upload_file(client, bucket_name, file_path)
  file_name = File.basename(file_path)  # Extract the file name from the file path
  obj = client.put_object({
    bucket: bucket_name,  # Name of the bucket
    key: file_name,  # Name of the object to be created
    body: File.read(file_path)  # File content
  })
  puts "File '#{file_name}' uploaded successfully to bucket '#{bucket_name}'"
rescue Aws::S3::Errors::ServiceError => e
  puts "Failed to upload file: #{e.message}"
end

# Command line options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-c", "--create-bucket BUCKET_NAME", "Create S3 bucket with the given name") do |bucket_name|
    options[:create_bucket] = bucket_name
  end

  opts.on("-u", "--upload-file FILE_PATH", "Upload file to the specified bucket") do |file_path|
    options[:upload_file] = file_path
  end

  opts.on("-b", "--bucket-name BUCKET_NAME", "Specify the S3 bucket name") do |bucket_name|
    options[:bucket_name] = bucket_name
  end

  opts.on("-r", "--region REGION", "Specify the AWS region") do |region|
    options[:region] = region
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

# Validate options
if options[:create_bucket].nil? && options[:upload_file].nil?
  puts "You must specify either --create-bucket or --upload-file option"
  exit
end

if options[:bucket_name].nil?
  puts "You must specify --bucket-name option"
  exit
end

region = options[:region] || 'ca-central-1'

# Initialize AWS S3 client
client = Aws::S3::Client.new(region: region)  # Creating a new instance of the S3 client with the specified region

# Execute functions based on CLI options
if options[:create_bucket]
  create_bucket(client, options[:bucket_name], region)
end

if options[:upload_file]
  if File.exist?(options[:upload_file])
    upload_file(client, options[:bucket_name], options[:upload_file])
  else
    puts "The file path '#{options[:upload_file]}' does not exist. Please provide a valid file path."
  end
end


#ruby s3.rb --create-bucket my-ruby-bucket-234 --bucket-name my-ruby-bucket-234 --region ca-central-1
#ruby s3.rb --upload-file file.txt --bucket-name my-ruby-bucket-234 --region ca-central-1

