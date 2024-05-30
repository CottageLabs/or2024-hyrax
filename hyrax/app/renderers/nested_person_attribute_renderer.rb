class NestedPersonAttributeRenderer < NestedAttributeRenderer
  def attribute_value_to_html(input_value)
    html = ''
    return html if input_value.blank?
    value = parse_value(input_value)
    value.each do |v|
      each_html = ''
      # creator name
      if v.dig('name').present? and v['name'].present?
        label = "Name"
        val = link_to(ERB::Util.h(v['name']), search_path(v['name']))
        each_html += get_row(label, val)
      else
        creator_name = []
        
        unless v.dig('first_name').blank?
          creator_name << v['first_name']
        end

        unless v.dig('last_name').blank?
          creator_name << v['last_name']
        end

        creator_name = creator_name.join(' ').strip
        if creator_name.present?
          label = "Name"
          val = link_to(ERB::Util.h(creator_name), search_path(creator_name))
          each_html += get_row(label, val)
        end
      end

      # role
      unless v.dig('role').blank?
        label = 'Role'
        val = v['role']
        term = RoleService.new.find_by_id(val)
        val = term['id'] if term.any? #using id as proxy for English-only text
        each_html += get_row(label, val)
      end

      # Workaround for nested properties
      # orcid
      unless v.dig('orcid').blank?
        label = 'ORCID'
        val = v['orcid']
        each_html += get_row(label, val)
      end

      # affiliation
      unless v.dig('affiliation').blank?
        label = 'Affiliation'
        val = v['affiliation']
        each_html += get_row(label, val)
      end
     
      html += get_inner_html(each_html)
    end
    html_out = get_ouput_html(html)
    %(#{html_out})
  end
end
