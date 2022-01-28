## Not maintened

# Debitech

[![Ruby CI](https://github.com/barsoom/debitech/actions/workflows/ci.yml/badge.svg)](https://github.com/barsoom/debitech/actions/workflows/ci.yml)

This is a DebiTech payment library extracted from production code.

You can use this to do subscription payments without needing to handle any credit card information yourself.

If you want something more low-level, check the [debitech_soap](https://github.com/joakimk/debitech_soap) gem, which this library uses for API access.

Setting up payments using DebiTech (one of the two payment systems run by DIBS) is not trivial,
but it seems there are not many good options in Sweden yet. Atleast using this you don't need to
figure out things like how to validate responses or how to not double charge, etc.

Todo:

* Example app
* Page set templates (the pages that are shown at DIBS to input credit card info)
* Rake tasks to update page sets

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'debitech'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install debitech

## Usage: Preparation

Get the API docs in DIBS manager, setup the account.

    TODO: Someone could send a pull request with more docs here on how to setup a new
          account, what to consider and what you should ask the support for.

## Usage: Adding a credit card

```erb
# MAC:    Secret key shared by your app and DIBS, get it from the DIBS manager
# METHOD: Something like cc.cekab, check the docs or ask support.
debitech_web_config = {
  :merchant => "ACCOUNT_NAME",
  :secret_key => "MAC",
  :fields => { :method => "METHOD", pageSet: "my-default-pageset" }
}

# In the view: form to redirect the user to DIBS
<% api = Debitech::WebApi.new(debitech_web_config) %>
# You can optionally pass a hash of further custom fields.
# Note that if you override the "currency" here, you will also need to pass it explicitly into `valid_response?`.
<% custom_fields = { pageSet: "my-custom-pageset" } %>
<form accept-charset="iso-8859-1" action="<%= api.form_action %>" method="post">
  <% api.form_fields(custom_fields).each do |name, value| %>
    <input name="<%= name %>" type="hidden" value="<%= value %>">
  <% end %>

  <!-- send translation strings, redirect back urls, etc here -->
  <input name="redirect_back_url" type="hidden" value="https://yourapp/credit_cards">
</form>
```

```ruby
# When you get the response back (TODO: add example templates)
api.valid_response?(mac, sum, reply, verify_id) # is the response from DIBS?
api.valid_response?(mac, sum, reply, verify_id, currency, reference_number) # if the request included "referenceNo", do this instead
api.approved_reply?(reply)                      # was the card added successfully?

# Store verify_id as your reference to the card.
```

## Usage: Charging a credit card

Configuration:

```ruby
# METHOD, MAC, ACCOUNT_NAME: Just like with the Web Api.
# API_USER, API_PASSWORD:    A API user you can create in DIBS manager.
debitech_server_config = {
  :method => "METHOD",
  :secret_key => "MAC",
  :soap_opts => {
    :merchant => "ACCOUNT_NAME",
    :username => "API_USER",
    :password => "API_PASSWORD"
  }
}
```

First try to get "valid_credentials?" to return true using [debitech_soap](https://github.com/joakimk/debitech_soap). If it does not work, try to regenerate the password for the API user. Some characters are not possible with the SOAP library.

Charging a credit card:

```ruby
debitech = Debitech::ServerApi.new(debitech_server_config)

# VERIFY_ID:        The id you get back when registering a card.
# AMOUNT:           The amount to charge, must be in cents (1 SEK = 100).
# IP:               The ip, can be "127.0.0.1", but the request ip is probably more useful.
# UNIQUE_REFERENCE: A unique reference, you want this to be something like invoice-NUM, so that you can search for it
#                   in DIBS manager with "invoice*". This is required so that you don't charge more than once for a
#                   single payment by accident. Must be atleast 5 characters long.

debitech.charge(:verify_id => verify_id,
                :amount => AMOUNT,
                :unique_reference => "UNIQUE_REFERENCE",
                :currency => "SEK",
                :ip => "IP")
```

This returns a Debitech::ServerApi::ChargeResult, check [server_api.rb](https://github.com/barsoom/debitech/blob/master/lib/debitech/server_api.rb).

In case it's "pending?", you can try again later with the same unique reference. The status is probably due to some temporary timeout or error between DIBS and the bank systems.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits and license

By [Joakim Kolsjö](https://github.com/joakimk) for [Barsoom](http://barsoom.se) under the MIT license.

Contributors:

* [Tobias Bohwalli](https://github.com/futhr)

>  Copyright (c) 2013 Barsoom AB
>
>  Permission is hereby granted, free of charge, to any person obtaining a copy
>  of this software and associated documentation files (the "Software"), to deal
>  in the Software without restriction, including without limitation the rights
>  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
>  copies of the Software, and to permit persons to whom the Software is
>  furnished to do so, subject to the following conditions:
>
>  The above copyright notice and this permission notice shall be included in
>  all copies or substantial portions of the Software.
>
>  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
>  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
>  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
>  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
>  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
>  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
>  THE SOFTWARE.
