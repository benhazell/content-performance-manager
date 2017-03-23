class ContentItemDecorator < Draper::Decorator
  delegate_all

  def title
    context[:title] || object.title
  end

  def description
    context[:description] || object.description
  end

  def document_type
    context[:document_type] || object.document_type
  end

  def url
    "https://gov.uk#{context[:base_path] || object.base_path}"
  end

  def last_updated
    date = context[:public_updated_at] || object.public_updated_at
    if date
      "#{helpers.time_ago_in_words(date)} ago"
    else
      "Never"
    end
  end

  def organisation_links
    names = object.organisations.collect do |organisation|
      helpers.link_to(organisation.title, helpers.content_items_path(organisation_slug: organisation.slug))
    end

    names.join(', ').html_safe
  end

  def taxons_as_string
    object.taxonomies.map(&:title).join(', ')
  end
end
