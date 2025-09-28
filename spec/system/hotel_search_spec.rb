require 'rails_helper'

RSpec.describe 'Hotel Search Widget', type: :system do
  before do
    # Configure test environment
    Rails.application.config.cache_store = :memory_store
    Rails.cache.clear
  end

  describe 'search flow' do
    it 'allows user to search for hotels' do
      visit root_path

      # Check that the widget is rendered
      expect(page).to have_content('Find Your Perfect Hotel')
      expect(page).to have_field('location')
      expect(page).to have_button('Search Hotels', disabled: true)

      # Fill in location (simulate typing)
      fill_in 'location', with: 'New York'
      
      # Wait for location suggestions (mocked)
      expect(page).to have_content('Location')

      # Fill in dates
      fill_in 'Check-in', with: '2024-01-15'
      fill_in 'Check-out', with: '2024-01-20'

      # Set number of adults
      within('.guest-input') do
        fill_in 'adults', with: '2'
      end

      # Search button should now be enabled
      expect(page).to have_button('Search Hotels', disabled: false)

      # Mock the search results
      allow(External::Hotels).to receive(:search).and_return({
        'hotels' => [
          {
            'name' => 'Grand Hotel',
            'price' => 150,
            'location' => 'New York',
            'rating' => 4.5
          }
        ]
      })

      # Click search button
      click_button 'Search Hotels'

      # Should show loading state
      expect(page).to have_button('Searching...', disabled: true)

      # Wait for results to appear
      expect(page).to have_content('Search Results')
      expect(page).to have_content('Grand Hotel')
      expect(page).to have_content('$150')
      expect(page).to have_content('⭐ 4.5/5')
    end

    it 'shows error message when search fails' do
      visit root_path

      # Fill in required fields
      fill_in 'location', with: 'New York'
      fill_in 'Check-in', with: '2024-01-15'
      fill_in 'Check-out', with: '2024-01-20'
      fill_in 'adults', with: '2'

      # Mock API error
      allow(External::Hotels).to receive(:search)
        .and_raise(External::Hotels::Error.new('API Error'))

      click_button 'Search Hotels'

      # Should show error message
      expect(page).to have_content('API Error')
    end

    it 'validates required fields' do
      visit root_path

      # Try to search without filling required fields
      click_button 'Search Hotels'
      expect(page).to have_button('Search Hotels', disabled: true)
    end

    it 'shows raw JSON toggle' do
      visit root_path

      # Complete search flow first
      fill_in 'location', with: 'New York'
      fill_in 'Check-in', with: '2024-01-15'
      fill_in 'Check-out', with: '2024-01-20'
      fill_in 'adults', with: '2'

      allow(External::Hotels).to receive(:search).and_return({
        'hotels' => [{ 'name' => 'Test Hotel' }]
      })

      click_button 'Search Hotels'

      # Should show results
      expect(page).to have_content('Search Results')

      # Toggle to raw JSON view
      click_button 'Show Raw JSON'
      expect(page).to have_content('{')
      expect(page).to have_content('"hotels"')

      # Toggle back to cards
      click_button 'Show Cards'
      expect(page).to have_content('Test Hotel')
    end
  end

  describe 'guest selector' do
    it 'allows adjusting number of adults and children' do
      visit root_path

      within('.guest-inputs') do
        # Test adults increment
        click_button '+'
        expect(find_field('adults').value).to eq('2')

        # Test adults decrement
        click_button '−'
        expect(find_field('adults').value).to eq('1')

        # Test children increment
        within(all('.guest-input').last) do
          click_button '+'
          expect(find_field('children').value).to eq('1')
        end
      end
    end
  end

  describe 'date picker' do
    it 'enforces valid date ranges' do
      visit root_path

      # Set check-in date
      fill_in 'Check-in', with: '2024-01-15'

      # Try to set check-out before check-in
      fill_in 'Check-out', with: '2024-01-10'

      # The check-out should be cleared or invalid
      expect(find_field('Check-out').value).to be_empty
    end
  end
end

