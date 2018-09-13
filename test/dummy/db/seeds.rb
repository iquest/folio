# frozen_string_literal: true

require 'faker'

Folio::Atom::Base.destroy_all
Folio::Node.destroy_all
Folio::Site.destroy_all
Folio::Account.destroy_all
Folio::Lead.destroy_all
Folio::Menu.destroy_all

def unsplash_pic(square = false)
  image = Folio::Image.new
  scale = 0.5 + rand / 2
  image.file_url = "https://picsum.photos/#{scale * 2560}/#{square ? scale * 2560 : scale * 1440}/?random"
  image.save!
  image
end

2.times { unsplash_pic }

site = Folio::Site.create!(title: 'Sinfin.digital',
                           domain: 'sinfin.localhost',
                           locale: 'cs',
                           locales: ['cs', 'en', 'de'],
                           email: 'info@sinfin.cz',
                           phone: '+420 123 456 789',
                           social_links: {
                            facebook: 'https://www.facebook.com/',
                            instagram: 'https://www.instagram.com/',
                            twitter: 'https://www.twitter.com/',
                           })

about = Folio::Page.create!(title: 'O nás',
                            published: true)
about.cover = unsplash_pic
3.times { about.images << unsplash_pic }

reference = Folio::Category.create!(title: 'Reference',
                                    published: true,
                                    published_at: 1.day.ago)
Folio::Page.create!(title: 'Smart Cities', parent: reference, published: true)
Folio::Page.create!(title: 'Vyvolej.to', parent: reference, published: true)
Folio::Page.create!(title: 'Hidden', parent: reference, published: false)
Folio::Page.create!(title: 'DAM', parent: reference, published: true)

menu = Folio::Menu::Page.create!(locale: :cs)

Folio::MenuItem.create!(menu: menu,
                        title: 'Reference',
                        target: reference,
                        position: 0)

Folio::MenuItem.create!(menu: menu,
                        title: 'About',
                        target: about,
                        position: 1)

Folio::Account.create!(email: 'test@test.test',
                       password: 'test@test.test',
                       role: :superuser,
                       first_name: 'Test',
                       last_name: 'Dummy')

nestable_menu = Menu::Nestable.create!(locale: :cs)
Folio::MenuItem.create!(menu: nestable_menu,
                        title: 'Reference',
                        target: reference,
                        position: 0)
wrap = Folio::MenuItem.create!(menu: nestable_menu,
                               title: 'Wrap',
                               position: 1)
[reference, about].each do |target|
  Folio::MenuItem.create!(menu: nestable_menu,
                          target: target,
                          parent: wrap)
end

about_en = about.translate!(:en)
about_en.update(title: 'About', published: true)
about.translate!(:de)
