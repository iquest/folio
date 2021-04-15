# Folio
Folio is CMS engine, which enables You to build application **pages from atoms** (tiny blocks with various behavior) **and molecules** (container for set of atoms).

This is done in `/console`.

In (Folio) Console You can also enable catalog-type management of models from Your application (eg. Users, Posts, Products ...), see [Scaffolding](#markdown-header-scaffolding).

## Installation
### Build Your app with Sprockets, not Webpacker
Folio uses Sprockets assets pipeline and PostgreSQL, so please build Your app with this in mind.

```bash
 $ rails new my_app --skip-yarn --skip-bootsnap --skip-webpack-install -d postgresql
```

or in existing app with Webpacker

- in `Gemfile`
  - delete `gem "webpacker"`
  - add
    ```ruby
    gem 'sprockets', '~> 4'
    gem 'sprockets-rails', require: 'sprockets/railtie'
    ```
- replace content of `app/assets/config/manifets.js` with
  ```javascript
  //= link application.js
  //= link application.css
  ```
- change in `app/views/layout/application.html.erb`  helper `javascript_pack_tag` to `javascript_include_tag`


### Add Folio gem

Add this line to your application's Gemfile:

```ruby
gem 'folio', github: 'sinfin/folio'
```

And then execute:

```bash
$ bundle
$ rails generate folio:install
```

This will copy bunch of things into your, hopefully clean, app. Verify that `config/database.yml` is set according to Your needs.

And then execute:

```bash
$ bundle
$ rails db:migrate
$ rails db:seed
```

which should add folio tables and some crucial records (default account and `Folio::Page`).

Take a look to, not only Folio, handy generators by
```bash
$ rails g
```
## Note about Redactor
If you want to use `:richtext` fields, you will need to buy a licence for [Redactor editor](https://imperavi.com/redactor/), and copy its files
to `vendor/assets/assets/redactor` of your app.
If you don't, just create that folder with empty `redactor.js` and `redactor.css` files in it.

## Attachments

### Image metadata module

If you want to analyse and store all Exif & IPTC data from uploaded Image files
you have to install ExifTool (https://www.sno.phy.queensu.ca/~phil/exiftool/index.html).

Ubuntu: `sudo apt install exiftool`
MacOS: `brew install exiftool`

Every uploaded file will be processed and all the metadata will be saved
to the `Folio::Image.file_metadata` field.

For a manual analysis of a file call `Dragonfly.app.fetch(Folio::Image.last.file_uid).metadata`
or `rake folio:file:metadata` for batch processing of already downloaded but not
 processed files.

## Scaffolding

Easily scaffold console controller and views for existing models.

```bash
$ rails generate folio:console:scaffold ModelName
```
Then add correct routes to `config/routes`
```
scope module: :folio do
  namespace :console do
    ...
    resources :model_names
    ...
  end
end
```
and update Folio console config (`config/initializers/folio.rb`) to see this `ModelName` in console menu
```
Rails.application.config.folio_console_sidebar_link_class_names = [
  %w[
    ...
    ModelName
  ],
  %w[...]
  ....
```

## Tips and Tricks
- Check [Wiki](https://github.com/sinfin/folio/wiki)

- If  class responds to `:console_sidebar_count` , such number is displayed in Folio console sidebar
- If aasm event have option `confirm`, confirmation alert is displayed in change (in Foio console). You can pass `true` (defaults to `t("folio.console.confirmation")`) or string ` event :pay, confirm: "Do You really want to pay this" do ... end`

## Contributing

Clone & setup

```
git clone git@github.com:sinfin/folio.git
cd folio
bundle install
bin/rails db:setup
```

Run

```
bin/rails s
```

For fully function dummy app You need to copy `redactor` files to `test/dummy/vendor` (see above). Try to use/study `bundle exec rails app:folio:prepare_dummy_app`.


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
