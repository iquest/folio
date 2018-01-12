# frozen_string_literal: true

require 'faker'
I18n.reload!

FactoryGirl.define do
  factory :folio_site, class: Folio::Site do
    title { Faker::Lorem.word }
    domain { Faker::Internet.domain_name }
    social_links { { 'facebook' => Faker::Internet.url('facebook.com') } }
    address { [Faker::Address.street_address, Faker::Address.city].join("\n") }
    phone { Faker::PhoneNumber.phone_number }
    locale :cs
  end

  factory :folio_node, class: Folio::Node do
    locale :cs
    title { Faker::Lorem.word }
    association :site, factory: :folio_site

    factory :folio_node_with_atoms do
      transient do
        atoms_count 3
      end
      after(:create) do |node, evaluator|
        node.atoms = create_list(:folio_atom, evaluator.atoms_count)
      end
    end
  end

  factory :folio_category, parent: :folio_node, class: Folio::Category
  factory :folio_page, parent: :folio_node, class: Folio::Page

  factory :folio_atom, class: Folio::Atom do
    content { Faker::Lorem.paragraph }
    association :node, factory: :folio_node
  end

  factory :folio_image, class: Folio::Image do
    file Folio::Engine.root.join('test/fixtures/folio/test.gif')
  end

  factory :folio_lead, class: Folio::Lead do
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    note { Faker::Lorem.paragraph }
  end

  factory :folio_admin_account, class: Folio::Account do
    email 'test@test.com'
    password '123456'
    role :superuser
    first_name 'Test'
    last_name 'Dummy'
  end

  factory :folio_menu, class: Folio::Menu::Header do
    factory :folio_menu_with_menu_items do
      transient do
        posts_count 3
      end

      after(:create) do |menu, evaluator|
        create_list(:folio_menu_item, evaluator.posts_count, menu: menu)
      end
    end
  end

  factory :folio_menu_item, class: Folio::MenuItem do
    association :node, factory: :folio_node
    title { Faker::Lorem.word }
    position 0
  end
end
