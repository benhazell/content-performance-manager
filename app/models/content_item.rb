class ContentItem < ApplicationRecord
  attr_accessor :proxy

  has_and_belongs_to_many :organisations
  has_and_belongs_to_many :taxonomies

  def title
    proxy[:title]
  end

  def description
    proxy[:description]
  end

  def document_type
    proxy[:document_type]
  end

  def public_updated_at
    proxy[:public_updated_at]
  end

  def url
    "https://gov.uk#{proxy[:base_path]}"
  end

  def self.create_or_update!(attributes)
    content_id = attributes.fetch(:content_id)
    content_item = self.find_or_create_by(content_id: content_id)

    content_item.add_organisations_by_title(attributes.fetch(:organisations))
    content_item.add_taxonomies_by_id(attributes.fetch(:taxons))

    attributes = content_item.existing_attributes(attributes)
    content_item.update!(attributes)
  end

  def add_organisations_by_title(orgs)
    orgs.each do |org|
      organisation = Organisation.find_by(title: org[:title])
      organisations << organisation unless organisation.nil? || organisations.include?(organisation)
    end
  end

  def add_taxonomies_by_id(taxons)
    taxons.each do |t|
      taxon = Taxonomy.find_by(content_id: t[:content_id])
      taxonomies << taxon unless taxon.nil? || taxonomies.include?(taxon)
    end
  end

  def existing_attributes(attributes)
    attributes.slice(*self.attributes.symbolize_keys.keys)
  end

# private

  def proxy
    @proxy ||= ContentItemsService.new.get(content_id)
  end
end
