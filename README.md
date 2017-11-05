# Thunderstone Leads
#### Generating them leads for the homies at ⚡️stone Radio

### Configuration
Set the following env variables:

**SOUNDCLOUD_CLIENT**


### To start

```bundle install```

``` bundle exec rake sidekiq:get_leads ```

In a separate window, start the sidekiq server

``` bundle exec sidekiq ```
