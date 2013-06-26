module Spree
  class ImportError < StandardError; end;

  class Oxxo < ActiveRecord::Base
    attr_accessible :oxxo_file
    has_attached_file :oxxo_file, 
			:path => ':rails_root/public/spree/order_data/data-files/:basename.:extension',
			:url => '/spree/order_data/data-files/:basename.:extension'

    validates_attachment_presence :oxxo_file
    serialize :order_ids, Array

    cattr_accessor :settings

    require 'csv'
    require 'pp'
    require 'open-uri'
    require 'tempfile'

    state_machine :initial => :created do

      event :start do
        transition :to => :started, :from => :created
      end
      event :complete do
        transition :to => :completed, :from => :started
      end
      event :failure do
        transition :to => :failed, :from => :started
      end

      before_transition :to => [:failed] do |import|
        import.order_ids = []
        import.failed_at = Time.now
        import.completed_at = nil
      end

      before_transition :to => [:completed] do |import|
        import.failed_at = nil
        import.completed_at = Time.now
      end
    end

    def state_datetime
      if failed?
        failed_at
      elsif completed?
        completed_at
      else
        Time.now
      end
    end
      
    def import_data!(_transaction=true)
      start
      if _transaction
        transaction do
          _import_data
        end
      else
        _import_data
      end
    rescue Exception => exp
      log("An error occurred during import, please check file and try again. (#{exp.message})\n#{exp.backtrace.join('\n')}", :error)
      failure
      raise ImportError, exp.message
    end

    def _import_data
      unless Spree::Oxxo.settings[:aws]
        rows = CSV.read(self.oxxo_file.path)
      else
        _tempile 'import', 'csv', open(self.oxxo_file.url).read
        csv_file = "#{Rails.root}/tmp/import_oxxo_csv_#{Process.pid}"
        rows = CSV.read(csv_file)
      end
      
      headers= Spree::Oxxo.settings[:column_mappings]

      log("Importing orders for #{self.oxxo_file_file_name} began at #{Time.now}")
      rows[Spree::Oxxo.settings[:rows_to_skip]..-1].each do |row|
        order_information = {}
        
        headers.each do |k, v|
          order_information[k] = row[v]
        end

        check_order_paid(order_information)
      end

      complete
      return [:notice, "Product data was successfully imported."]
    end
    
    private
    def check_order_paid(order)
      log "\n Order to pay \n"
      log "\n #{pp order} \n\n"
      payment = Spree::Payment.find_by_barcode(_barcode(order))
      begin
        unless payment.state == "completed"
          payment.complete!
          Spree::OrderUpdater.new(payment.order).update_payment_state
        end
      rescue
        log "Not exists your order"
      end
    end

    def _barcode order
      if order[:rpu2].to_i > 1
        code = (order[:rpu1] + order[:rpu2]).gsub(' ', '')
        last_position = code.index('0000000000')
        code[0..last_position - 1]
      else
        order[:rpu1]
      end
    end

		def _tempfile name, extension, data
			file = Tempfile.open([name, ".#{extension}"],"#{Rails.root}/tmp/")
			begin
				file.binmode
				file.write(data)
			ensure
				file.close
			end
			
			if extension == 'csv'
				File.rename(file.path, "#{Rails.root}/tmp/#{name}_oxxo_csv_#{Process.pid}")
			else
				File.rename(file.path, "#{Rails.root}/tmp/#{name}.#{extension}")
			end
			file.unlink
		end

    ### MISC HELPERS ####

    #Log a message to a file - logs in standard Rails format to logfile set up in the import_products initializer
    #and console.
    #Message is string, severity symbol - either :info, :warn or :error

    def log(message, severity = :info)
      @rake_log ||= ActiveSupport::BufferedLogger.new(Spree::Oxxo.settings[:log_to])
      message = "[#{Time.now.to_s(:db)}] [#{severity.to_s.capitalize}] #{message}\n"
      @rake_log.send severity, message
      puts message
    end

  end
end
