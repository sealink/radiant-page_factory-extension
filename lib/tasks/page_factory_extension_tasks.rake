namespace :radiant do
  namespace :extensions do
    namespace :page_factory do

      namespace :refresh do
        task :update_parts, :factory, :needs => :environment do |task, args|
          updated = PageFactory::Manager.update_parts args[:factory]
          puts "Added missing parts from #{updated.join(', ')}"
        end
        task :prune_parts, :factory, :needs => :environment do |task, args|
          updated = PageFactory::Manager.prune_parts! args[:factory]
          puts "Removed extra parts from #{updated.join(', ')}"
        end
        task :sync_parts, :factory, :needs => :environment do |task, args|
          updated = PageFactory::Manager.sync_parts! args[:factory]
          puts "Synchronized part classes on #{updated.join(', ')}"
        end
        task :sync_layouts, :factory, :needs => :environment do |task, args|
          updated = PageFactory::Manager.sync_layouts! args[:factory]
          puts "Synchronized layouts on #{updated.join(', ')}"
        end
        desc "Add missing page parts, but don't change or remove any data."
        task :soft, :factory, :needs => :environment do |task, args|
          Rake::Task['radiant:extensions:page_factory:refresh:update_parts'].invoke args[:factory]
        end
        desc "Make pages look exactly like their class definitions, including layout and part classes"
        task :hard, :factory, :needs => :environment do |task, args|
          Rake::Task['radiant:extensions:page_factory:refresh:prune_parts'].invoke args[:factory]
          Rake::Task['radiant:extensions:page_factory:refresh:sync_parts'].invoke args[:factory]
          Rake::Task['radiant:extensions:page_factory:refresh:update_parts'].invoke args[:factory]
          Rake::Task['radiant:extensions:page_factory:refresh:sync_layouts'].invoke args[:factory]
        end
      end
      
      desc "Runs the migration of the Page Factory extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          PageFactoryExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          PageFactoryExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Page Factory to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from PageFactoryExtension"
        Dir[PageFactoryExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(PageFactoryExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
        unless PageFactoryExtension.root.starts_with? RAILS_ROOT # don't need to copy vendored tasks
          puts "Copying rake tasks from PageFactoryExtension"
          local_tasks_path = File.join(RAILS_ROOT, %w(lib tasks))
          mkdir_p local_tasks_path, :verbose => false
          Dir[File.join PageFactoryExtension.root, %w(lib tasks *.rake)].each do |file|
            cp file, local_tasks_path, :verbose => false
          end
        end
      end  
      
      desc "Syncs all available translations for this ext to the English ext master"
      task :sync => :environment do
        # The main translation root, basically where English is kept
        language_root = PageFactoryExtension.root + "/config/locales"
        words = TranslationSupport.get_translation_keys(language_root)
        
        Dir["#{language_root}/*.yml"].each do |filename|
          next if filename.match('_available_tags')
          basename = File.basename(filename, '.yml')
          puts "Syncing #{basename}"
          (comments, other) = TranslationSupport.read_file(filename, basename)
          words.each { |k,v| other[k] ||= words[k] }  # Initializing hash variable as empty if it does not exist
          other.delete_if { |k,v| !words[k] }         # Remove if not defined in en.yml
          TranslationSupport.write_file(filename, basename, comments, other)
        end
      end
    end
  end
end
