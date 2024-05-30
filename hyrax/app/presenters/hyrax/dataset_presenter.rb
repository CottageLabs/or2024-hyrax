module Hyrax
  class DatasetPresenter < Hyrax::WorkShowPresenter
    delegate :complex_person, to: :solr_document
  end
end
