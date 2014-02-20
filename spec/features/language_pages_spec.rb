#require('rspec')
require "spec_helper"

describe 'Language Pages' do
  let(:language) { create(:language) }

  describe "index" do
    it "can list several" do
      langs = build_stubbed_list(:language, 3)
      Language.stub(all: langs)
      visit languages_path
    end
    it "links to new" do
      visit languages_path
      page.should have_link_to(new_language_path)
    end
    it "is linked from home" do
      visit root_path
      page.should have_link_to(languages_path)
    end
  end

  describe "new" do
    it "displays" do
      visit new_language_path
    end
    it "works" do
      LocalizedTextEnforcer.any_instance.should_receive(:language_created)
      visit new_language_path
      page.should have_css("form.language")
      fill_in "language_code", with: 'FR'
      fill_in "language_name", with: 'Frenchie'
      click_on "Save"
      page.should_not have_css("form.language")
    end
    it "displays errors" do
      visit new_language_path
      page.should have_css("form.language")
      fill_in "language_name", with: 'fr'
      click_on "Save"
      page.should have_css("form.language")
      page.should have_css("form.language .errors")
    end
  end
  describe "edit" do
    before { visit edit_language_path(language) }
    it "displays" do
      visit new_language_path
    end
    it "works" do
      page.should have_css("form.language")
      fill_in "language_name", with: 'Franglais'
      click_on "Save"
      page.should_not have_css("form.language")
    end
    it "displays errors" do
      page.should have_css("form.language")
      fill_in "language_name", with: ''
      click_on "Save"
      page.should have_css("form.language")
      page.should have_css("form.language .errors")
    end
  end


  describe "translations" do
    let(:ok_localized_text) { create(:localized_text, language: language, text: "zongy-bo!") }
    let(:empty_localized_text) { create(:localized_text, language: language, text: "") }
    let(:needs_review_localized_text) { create(:localized_text, language: language,
        text: "something new", needs_review: true) }
    let(:localized_texts) { [ok_localized_text, empty_localized_text, needs_review_localized_text] }

    before { language }

    shared_examples_for "localized text list" do
      it "displays one" do
        localized_text
        visit path
        page.should have_content(localized_text.master_text.text)
        page.should have_css("#localized_text_#{localized_text.id}")
      end
      it "updates one" do
        localized_text
        visit path
        fill_in :language_localized_texts_attributes_0_text, with: "flounce"
        click_on "Save"
        visit language_texts_path(language)
        page.should have_content("flounce")
      end
      it "linked from index" do
        visit languages_path
        page.should have_link_to(path)
      end
      it "linked from all" do
        visit language_texts_path(language)
        page.should have_link_to(path)
      end
      it "linked from entry" do
        visit entry_language_texts_path(language)
        page.should have_link_to(path)
      end
      it "linked from review" do
        visit review_language_texts_path(language)
        page.should have_link_to(path)
      end
      it "is active" do
        visit path
        within "ul.localized-texts.nav li.active" do
          page.should have_link_to(path)
        end
      end
    end
    describe "all" do
      let(:localized_text) { ok_localized_text }
      let(:path) { language_texts_path(language) }
      it_behaves_like "localized text list"

      it "displays all" do
        localized_texts
        visit path
        localized_texts.each do |localized_text|
          page.should have_css("#localized_text_#{localized_text.id}")
        end
      end
    end

    describe "translations to enter" do
      let(:localized_text) { empty_localized_text }
      let(:path) { entry_language_texts_path(language) }
      it_behaves_like "localized text list"
      it "displays appropriate" do
        localized_texts
        visit path
        page.should have_css("#localized_text_#{empty_localized_text.id}")
        page.should_not have_css("#localized_text_#{ok_localized_text.id}")
        page.should_not have_css("#localized_text_#{needs_review_localized_text.id}")
      end
    end

    describe "translations to review" do
      let(:localized_text) { needs_review_localized_text }
      let(:path) { review_language_texts_path(language) }
      it_behaves_like "localized text list"
      it "displays all" do
        localized_texts
        visit path
        page.should have_css("#localized_text_#{needs_review_localized_text.id}")
        page.should_not have_css("#localized_text_#{ok_localized_text.id}")
        page.should_not have_css("#localized_text_#{empty_localized_text.id}")
      end
    end
  end

end