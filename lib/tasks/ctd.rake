namespace :ctd do
  namespace :import do
    desc 'Imports the product list'
    task :products, [:csv_path] => [ :environment ]  do |t, args|
      require 'ctd/product_importer'
      args.with_defaults csv_path: "db/product_export.csv"
      importer = CTD::ProductImporter.new
      importer.import( args.csv_path )
    end
  end
end

