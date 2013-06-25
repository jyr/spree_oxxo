module SpreeOxxo
  module UserMailerExt
    def self.included(base)
      base.class_eval do
        def order_import_results(user, error_message = nil)
          @user = user
          @error_message = error_message
          attachments["import_orders.log"] = File.read(Spree::Oxxo.settings[:log_to]) if @error_message.nil?
          mail(:to => @user.email, :subject => "Spree: Import Orders #{error_message.nil? ? "Success" : "Failure"}")
        end
      end
    end
  end
end
