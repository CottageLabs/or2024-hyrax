# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Dataset`
class Dataset < Hyrax::Work
  attribute :complex_person , Valkyrie::Types::Array.of(Valkyrie::Types::String)
  include Hyrax::Schema(:core_metadata)
  include Hyrax::Schema(:dataset)
end
