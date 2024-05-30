class QaSelectServiceExtended < Hyrax::QaSelectService
  def label(id, &block)
    # Need to cater for use case when the metadata has a term not part of the authority
    begin
      authority.find(id).fetch('term', &block)
    rescue
      id
    end
  end

  def find_by_id_or_label(term, &block)
    a = authority.all.select { |e| (e[:label] == term || e[:id] == term) && e[:active] == true }
    if a.any?
      a.first
    else
      {}
    end
  end

  def find_by_id(term, &block)
    a = authority.all.select { |e| e[:id] == term && e[:active] == true }
    if a.any?
      a.first
    else
      {}
    end
  end

  def find_by_label(term, &block)
    a = authority.all.select { |e| e[:label] == term && e[:active] == true }
    if a.any?
      a.first
    else
      {}
    end
  end
end
