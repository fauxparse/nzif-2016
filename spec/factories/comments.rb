FactoryGirl.define do
  factory :comment do
    incident
    participant { create(:participant, user: create(:admin)) }
    content 'I agree'
  end
end
