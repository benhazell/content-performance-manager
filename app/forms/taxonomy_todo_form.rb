class TaxonomyTodoForm
  include ActiveModel::Model
  attr_accessor :taxonomy_todo, :new_terms, :existing_terms, :user

  delegate :title, :url, :description, to: :content_item

  def save
    TaxonomyTodo.transaction do
      update_todo
      save_existing_terms
      save_terms
    end
  end

  def content_item
    taxonomy_todo.content_item.decorate
  end

  def terms_for_select
    taxonomy_todo.taxonomy_project.terms.order(name: 'ASC')
  end

private

  def update_todo
    taxonomy_todo.update!(
      completed_at: Time.zone.now,
      completed_by: user.uid
    )
  end

  def save_existing_terms
    existing_terms.select(&:present?).each do |existing_term_id|
      taxonomy_todo.terms << Term.find(existing_term_id)
    end
  end

  def save_terms
    split_terms = new_terms.split(',').map(&:strip)

    split_terms.each do |term_text|
      term = Term.find_or_create_by!(
        name: term_text,
        taxonomy_project: taxonomy_todo.taxonomy_project
      )

      taxonomy_todo.terms << term
    end
  end
end
