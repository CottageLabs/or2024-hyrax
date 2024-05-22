module Hyrax
  class MonographPresenter < Hyrax::WorkShowPresenter
    delegate :record_info, :place_of_publication, :genre, :series_title, :target_audience, :table_of_contents, :date_of_issuance, to: :solr_document
  end
end
