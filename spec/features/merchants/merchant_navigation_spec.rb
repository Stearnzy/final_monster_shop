require 'rails_helper'

describe "As a merchant employee" do
  it "I see the links as a regular user plus a link to my dashboard" do
    merch_employee = User.create!({
      name: "Kyle",
      address: "333 Starlight Ave.",
      city: "Bakersville",
      state: "NV",
      zip: '90210',
      email: "kyle@email.com",
      password: "word",
      role: 1
      })

    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(merch_employee)


    visit '/'

    within '.topnav' do
      expect(page).to have_link('Profile')
      expect(page).to have_link('Logout')
      expect(page).to have_link('Home')
      expect(page).to have_link('All Merchants')
      expect(page).to have_link('All Items')
      expect(page).to have_link('Dashboard')

      expect(page).to_not have_link('Login')
      expect(page).to_not have_link('Register')
    end
  end
end