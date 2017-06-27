# lita-diabetes

[![Build Status](https://travis-ci.org/reddit-diabetes/lita-diabetes.svg)](https://travis-ci.org/reddit-diabetes/lita-diabetes)

A plugin for diabetes-related plugins for lita

## Installation

Add lita-diabetes to your Lita instance's Gemfile:

```ruby
gem "lita-diabetes", :git => "https://github.com/reddit-diabetes/lita-diabetes.git"
```

## Configuration

```ruby
# for values entered without units in this range the bot will
# respond with both conversions
# lower bound for ambiguious bg entries
config.handlers.diabetes.lower_bg_bound = '20'
# upper bound
config.handlers.diabetes.upper_bg_bound = '35'
```

## Usage

&lt;number&gt; - Convert glucose between mass/molar concentration units.

\_&lt;number&gt;_ - Convert glucose between mass/molar concentration units inline. E.g "I started at _125_ today"

&lt;number&gt; [mmol/l | mg/dl] - Convert glucose from specified units

Lita: estimate a1c [from average] &lt;glucose level&gt; - Estimates A1C based on average BG level

Lita: estimate average [from a1c] &lt;A1C&gt; - Estimates average blood glucose

## License

[MIT](http://opensource.org/licenses/MIT)
