# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Dataset`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class DatasetForm < Hyrax::Forms::PcdmObjectForm(Dataset)
  include Hyrax::FormFields(:core_metadata)
  property :complex_person, primary: true, required: true, populator: :complex_person_populator
  include Hyrax::FormFields(:dataset)

  private

  def complex_person_populator(fragment:, **_options)
    adds = []
    deletes = []
  
    fragment.each do |_, h|
      person_hash = h.slice("role", "orcid", "last_name", "first_name", "affiliation").permit!.to_h.to_hash
      person_hash = person_hash.transform_keys(&:to_sym) 
      if h["_destroy"] == "1"
        deletes << person_hash
      else
        if has_required_fields?(person_hash)
          adds << person_hash
        end
      end
    end
  
    # Add elements in `adds` to `complex_person`
    updated_persons = complex_person + adds
  
    # Remove elements in `deletes` from `updated_persons`
    remaining_persons = updated_persons.reject do |person|
      deletes.any? do |delete_person|
        delete_person == person
      end
    end

    self.complex_person = remaining_persons.uniq
  end

  def has_required_fields?(person_hash)
    person_hash[:first_name].present? && person_hash[:last_name].present? && person_hash[:role].present?
  end

  def self.permitted_person_params
    [ :id,
      :_destroy,
      :corresponding_author,
      :display_order,
      :last_name ,
      :first_name,
      :name,
      :role,
      :orcid,
      :affiliation
    ]
  end


  def self.build_permitted_params
    permitted = super
    permitted << { complex_person_attributes: permitted_person_params }
  end
end
