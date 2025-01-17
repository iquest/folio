# frozen_string_literal: true

FactoryBot.define do
  factory :folio_site, class: "Folio::Site" do
    title { "Folio" }
    sequence(:domain) { |n| "folio-#{n}.com" }
    email { "folio@folio.folio" }
    social_links { { "facebook" => "http://www.facebook.com/folio" } }
    address { "90682 Folio Square\nFolio" }
    phone { "+420 123456789" }
    locale { :cs }
    locales { [:cs] }
  end

  factory :folio_page, class: "Folio::Page" do
    locale { :cs }
    if Rails.application.config.folio_using_traco
      I18n.available_locales.each do |locale|
        sequence("title_#{locale}".to_sym) { |n| "Folio page #{n}" }
        sequence("slug_#{locale}".to_sym) { |n| "folio-page-#{n}" }
      end
    else
      sequence(:title) { |n| "Folio page #{n}" }
      sequence(:slug) { |n| "folio-page-#{n}" }
    end
    published { true }
    published_at { 1.day.ago }

    trait :unpublished do
      published { false }
      published_at { nil }
    end
  end

  factory :folio_page_cookies, parent: :folio_page, class: "Folio::Page::Cookies"

  factory :folio_document_placement, class: "Folio::FilePlacement::Document" do
    association :file, factory: :folio_document
    association :placement, factory: :folio_page
  end

  factory :folio_image_placement, class: "Folio::FilePlacement::Image" do
    association :file, factory: :folio_image
    association :placement, factory: :folio_page
  end

  factory :folio_cover_placement, class: "Folio::FilePlacement::Cover" do
    association :file, factory: :folio_image
    association :placement, factory: :folio_page
  end

  factory :folio_image, class: "Folio::Image" do
    file { Folio::Engine.root.join("test/fixtures/folio/test.gif") }

    trait :black do
      file { Folio::Engine.root.join("test/fixtures/folio/test-black.gif") }
    end
  end

  factory :folio_document, class: "Folio::Document" do
    file { Folio::Engine.root.join("test/fixtures/folio/empty.pdf") }
  end

  factory :folio_private_attachment, class: "Folio::PrivateAttachment" do
    file { Folio::Engine.root.join("test/fixtures/folio/empty.pdf") }
  end

  factory :folio_lead, class: "Folio::Lead" do
    email { "folio@folio.folio" }
    phone { "+420 123456789" }
    note { "Officiis perferendis commodi." }
  end

  factory :folio_admin_account, class: "Folio::Account" do
    email { "test@test.com" }
    password { "Complex@Password.123" }
    role { :superuser }
    first_name { "Test" }
    last_name { "Dummy" }
  end

  factory :folio_menu, class: "Folio::Menu::Page" do
    locale { :cs }
    sequence(:title) { |i| "Menu #{i}" }

    factory :folio_menu_with_menu_items do
      transient do
        items_count { 3 }
      end

      after(:create) do |menu, evaluator|
        create_list(:folio_menu_item, evaluator.items_count, menu: menu)
      end
    end
  end

  factory :dummy_menu, class: "Dummy::Menu::Navigation", parent: :folio_menu

  factory :folio_menu_item, class: "Folio::MenuItem" do
    association :menu, factory: :folio_menu
    association :target, factory: :folio_page
    title { "MenuItem" }
    position { 0 }
  end

  factory :folio_session_attachment_image,
          class: "Dummy::SessionAttachment::Image" do
    file { Folio::Engine.root.join("test/fixtures/folio/test.gif") }
    web_session_id { "web_session_id" }
  end

  factory :folio_session_attachment_document,
          parent: :folio_session_attachment_image,
          class: "Dummy::SessionAttachment::Document"

  factory :folio_email_template,
          class: "Folio::EmailTemplate" do
    mailer { "mailer" }
    action { "action" }
    title { "title" }
    subject_cs { "subject_cs" }
    subject_en { "subject_en" }
    body_html_cs { "body_html_cs" }
    body_html_en { "body_html_en" }
    body_text_cs { "body_text_cs" }
    body_text_en { "body_text_en" }
    optional_keywords { [] }
    required_keywords { [] }
  end

  factory :folio_user, class: "Folio::User" do
    sequence(:email) { |i| "email-#{i}@email.email" }
    password { "Complex@Password.123" }
    confirmed_at { Time.now }
    first_name { "first_name" }
    last_name { "last_name" }
  end

  factory :folio_newsletter_subscription, class: "Folio::NewsletterSubscription" do
    sequence(:email) { |i| "email-#{i}@email.email" }
  end
end
