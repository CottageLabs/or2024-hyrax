# frozen_string_literal: true

module ComplexField
  module PersonIndexer
    def to_solr
      super.tap do |solr_doc|
        index_person(solr_doc)
      end
    end

    def index_person(solr_doc)
      begin
        creators = resource.complex_person.map { |c| "#{c[:first_name]} #{c[:last_name]}"}
      rescue
        creators = []
      end

      creators = creators.flatten.uniq.reject(&:blank?)
      return solr_doc unless creators
      solr_doc['complex_person_tesim'] = creators
      solr_doc['complex_person_ssim'] = creators
      solr_doc['complex_person_sim'] = creators
      solr_doc['complex_person_ssm'] = resource.complex_person.to_json

      resource.complex_person.each do |c|
        # index creator by role
        person_name = "#{c[:first_name]} #{c[:last_name]}"
        label = 'other'
        role = c[:role]
        if role.present?
          begin
            label = RoleService.new.label(role)
            label = label.downcase.tr(' ', '_')
          rescue
            label = role.downcase.tr(' ', '_')
          end
        end
        # complex_person by role as stored_searchable
        fld_name = "complex_person_#{label}_tesim"
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        solr_doc[fld_name] << person_name
        solr_doc[fld_name].flatten!
        # complex_person by role as facetable
        fld_name = "complex_person_#{label}_ssim"
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        solr_doc[fld_name] << person_name
        solr_doc[fld_name].flatten!
        # affiliation
        vals = c[:affiliation]
        fld_name = "complex_person_affiliation_tesim"
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        solr_doc[fld_name] << vals
        solr_doc[fld_name] = solr_doc[fld_name].flatten.uniq
        fld_name = "complex_person_affiliation_ssim"
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        solr_doc[fld_name] << vals
        solr_doc[fld_name] = solr_doc[fld_name].flatten.uniq
        # orcid
        vals = c[:orcid]
        fld_name = 'complex_person_identifier_sim'
        solr_doc[fld_name] = [] unless solr_doc.include?(fld_name)
        solr_doc[fld_name] << vals
        solr_doc[fld_name] = solr_doc[fld_name].flatten.uniq
      end
    end
  end
end
