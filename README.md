Rspec Compact Doc Formatter
===============

Compact yet descriptive Rspec format.

Install
-------

```
gem install rspec-compact-doc-formatter
```

If you want to use this formatter as your default formatter, simply put the options in your .rspec file:

```
--format RspecCompactDocFormatter
```

Rails 3
-------

In your Gemfile:

```ruby
group :test do
  gem "rspec-compact-doc-formatter"
end
```

Usage
-----

```
rspec spec -f RspecCompactDocFormatter
```

Copyright
---------

Copyright (c) 2012 De Marque inc. See LICENSE for further details.
