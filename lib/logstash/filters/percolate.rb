require "logstash/filters/base"
require "logstash/namespace"
require "base64"


# This filter allows one to [percolate](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-percolate.html)
# the current event against ES stored queries and find which queries are matching the current event.
#
# The matching query ids will be returned in the `event[matches]` (default).
#
# [source,ruby]
#          #percolates the existing document having the id as specified in the event id field
#          percolate {
#             hosts => ["es-server"]
#             index => "my_index"
#             type => "my_type"
#             id => "%{id}"
#          }
#
#          # percolates the event itself
#          percolate {
#             hosts => ["es-server"]
#             index => "my_index"
#             type => "my_type"
#          }
#
#          # percolates the sub-structure available in event['my_field']
#          percolate {
#             hosts => ["es-server"]
#             index => "my_index"
#             type => "my_type"
#             target => "my_field"
#          }
#
class LogStash::Filters::Percolate < LogStash::Filters::Base
  config_name "percolate"

  # List of elasticsearch hosts to use for querying.
  config :hosts, :validate => :array, :required => true

  # Percolate index
  config :index, :validate => :string, :default => nil, :required => true

  # Percolate Type
  config :type, :validate => :string, :default => nil, :required => true

  # ID of an existing document. If no ID is provided, then the current event will be used as the percolated document.
  config :id, :validate => :string, :default => nil

  # Percolate count only
  config :count, :validate => :boolean, :default => false

  # If specified, percolates this target sub-field of the event instead of the whole event
  config :target, :validate => :string, :default => nil

  # Field to store the matches into
  config :result, :validate => :string, :default => 'matches'

  # Basic Auth - username
  config :user, :validate => :string

  # Basic Auth - password
  config :password, :validate => :password

  # SSL
  config :ssl, :validate => :boolean, :default => false

  # SSL Certificate Authority file
  config :ca_file, :validate => :path


  public
  def register
    require "elasticsearch"

    transport_options = {}

    if @user && @password
      token = Base64.strict_encode64("#{@user}:#{@password.value}")
      transport_options[:headers] = { Authorization: "Basic #{token}" }
    end

    hosts = if @ssl then
      @hosts.map {|h| { host: h, scheme: 'https' } }
    else
      @hosts
    end

    if @ssl && @ca_file
      transport_options[:ssl] = { ca_file: @ca_file }
    end

    @logger.info("New ElasticSearch percolate", :hosts => hosts)
    @client = Elasticsearch::Client.new hosts: hosts, transport_options: transport_options
  end # def register

  public
  def filter(event)
    begin
      # Percolate an existing document if an id is given
      if @id
        results = @client.percolate index: @index, type: @type, id: event.sprintf(@id)

      # Otherwise percolate the event itself or a sub-field thereof
      else
        doc = if @target then
          event[@target]
        else
          event
        end
        body = {'doc' => doc}

        results = @client.percolate index: @index, type: @type, body: body
      end

      # return the matches
      event[@result] = results['matches'].map{|m| m['_id']}

      filter_matched(event)
    rescue => e
      @logger.warn("Failed to percolate event",
                   :id => @id, :target => @target, :event => event, :error => e)
    end
  end # def filter
end # class LogStash::Filters::Percolate
