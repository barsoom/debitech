# Debitech

This is a DebiTech payment library extracted from production code.

You can use this to do subscription payments without needing to handle any
credit card information yourself.

Todo:

* Examples and documentation
* Gotchas about the debitech API
* Page set templates (the pages that are shown at DIBS to input credit card info)
* Rake tasks to update page sets

## Installation

Add this line to your application's Gemfile:

    gem 'debitech'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install debitech

## Usage: Preparation

Get the API docs in DIBS manager, setup the account.

    TODO: Someone could send a pull request with more docs here on
    how to setup a new account, what to consider and what you should
    ask the support for.

## Usage: Adding a credit card

    # MAC: Secret key shared by your app and DIBS, get it from the DIBS manager 
    # METHOD: Something like cc.cekab, check the docs or ask support.
    debitech_web_config = {
      :merchant => "ACCOUNT_NAME",
      :secret_key => "MAC",
      :fields => { :method => "METHOD" }
    }

    # In the view: form to redirect the user to DIBS
    <% api = Debitech::WebApi.new(debitech_web_config) %>
    <form accept-charset="iso-8859-1" action="<%= api.form_action %>" method="post">
      <% api.form_fields.each do |name, value| %>
        <input name="<%= name %>" type="hidden" value="<%= value %>">
      <% end %>

      <!-- send translation strings, redirect back urls, etc here -->
      <input name="redirect_back_url" type="hidden" value="http://yourapp/credit_cards">
    </form>

    # When you get the response back (TODO: add example templates)
    api.valid_response?(mac, sum, reply, verify_id) # is the response from DIBS?
    api.approved_reply?(reply)                      # was the card added successfully?

    # Store verify_id as your reference to the card.

## Usage: Charging a credit card

TODO: write docs

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits and license

By [Joakim Kolsjö](https://github.com/joakimk) for [Barsoom](http://barsoom.se) under the MIT license:

>  Copyright (c) 2012 Barsoom AB
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
