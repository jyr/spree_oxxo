module SpreeOxxo
  class ImportJob
    attr_accessor :order_import_id
    attr_accessor :user_id
    
    def initialize(order_import, user)
      self.order_import_id = order_import.id
      self.user_id = user.id
    end

    def perform
      begin
        order_import = Spree::Oxxo.find(self.order_import_id)
        results = order_import.import_data!(Spree::Oxxo.settings[:transaction])
        Spree::UserMailer.order_import_results(Spree::User.find(self.user_id)).deliver
      rescue Exception => exp
        Spree::UserMailer.order_import_results(Spree::User.find(self.user_id), exp.message).deliver
      end
    end

  end
end
