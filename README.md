# Logstash Plugin

[![Travis Build Status](https://travis-ci.org/logstash-plugins/logstash-filter-elasticsearch.svg)](https://travis-ci.org/logstash-plugins/logstash-filter-elasticsearch)

This is a plugin for [Logstash](https://github.com/elastic/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

Logstash provides infrastructure to automatically generate documentation for this plugin. We use the asciidoc format to write documentation so any comments in the source code will be first converted into asciidoc and then into html. All plugin documentation are placed under one [central location](https://www.elastic.co/guide/en/logstash/current/).

- For formatting code or config example, you can use the asciidoc `[source,ruby]` directive
- For more asciidoc formatting tips, see the excellent reference here https://github.com/elastic/docs#asciidoc-guide

## Using this plugin

This filter plugin runs very similarly to the [`elasticsearch` Logstash filter](https://github.com/logstash-plugins/logstash-filter-elasticsearch).

It supports percolation of ad-hoc and/or existing documents, e.g.

    # percolates the event itself
    percolate {
        hosts => ["localhost:9200"]
        index => "my_index"
        type => "my_type"
    }

    # percolates the sub-structure available in event['my_field']
    percolate {
        hosts => ["localhost:9200"]
        index => "my_index"
        type => "my_type"
        target => "my_field"
    }

    # percolates the existing document having the id as specified in the event id field
    percolate {
        hosts => ["localhost:9200"]
        index => "my_index"
        type => "my_type"
        id => "%{id}"
    }


*Important note:* this filter is only useful if you're using ES 2.x and earlier. The reason for this is that in ES 5.0 alpha2, the
[Percolate API has been deprecated](https://www.elastic.co/guide/en/elasticsearch/reference/master/breaking_50_percolator.html#_percolate_and_multi_percolator_apis)
in favor of a new [`percolate` query](https://www.elastic.co/guide/en/elasticsearch/reference/master/query-dsl-percolate-query.html) (see https://github.com/elastic/elasticsearch/pull/17560)
which will run like any other normal DSL query, and thus, allow the use of the existing [`elasticsearch`](https://www.elastic.co/guide/en/logstash/current/plugins-filters-elasticsearch.html)
Logstash filter in order to percolate documents on the fly.

## Need Help?

Need help? Try #logstash on freenode IRC or the https://discuss.elastic.co/c/logstash discussion forum.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization. We also provide [example plugins](https://github.com/logstash-plugins?query=example).

- Install dependencies
```sh
bundle install
```

#### Test

- Update your dependencies

```sh
bundle install
```

- Run tests

```sh
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Install plugin
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

You can use the same **2.1** method to run your plugin in an installed Logstash by editing its `Gemfile` and pointing the `:path` to your local plugin development directory or you can build the gem and install it using:

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
# Logstash 2.3 and higher
bin/logstash-plugin install --no-verify

# Prior to Logstash 2.3
bin/plugin install --no-verify

```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
