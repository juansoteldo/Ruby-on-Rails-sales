namespace :ctd do
  namespace :import do
    desc 'Imports the product list'
    task products: :environment  do
      require 'ctd/product_importer'

      importer = CTD::ProductImporter.new
      importer.import( Rails.root.join( 'db/products_export.csv' ) )
    end
  end
end

