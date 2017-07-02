namespace :import do
  desc 'Import all content items for all organisations'
  task all_content_items: :environment do
    Importers::AllContentItems.new.run
  end

  desc 'Import all taxons (without content items)'
  task all_taxons: :environment do
    Importers::AllTaxons.new.run
  end

  desc 'Import all the inventory'
  task all_inventory: :environment do
    Importers::AllInventory.new.run
  end

  desc 'Import GA metrics '
  task all_ga_metrics: :environment do
    Importers::AllGoogleAnalyticsMetrics.new.run
  end
end
