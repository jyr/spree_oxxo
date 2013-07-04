module Spree
  module Admin
    class OxxosController < BaseController

      def index
        @oxxo = Spree::Oxxo.new
      end

      def create
        @order_import = Spree::Oxxo.create(params[:oxxo])
        Delayed::Job.enqueue SpreeOxxo::ImportJob.new(@order_import, current_user)
        flash[:notice] = t('oxxo.order_processing')
        redirect_to admin_oxxos_path
      end

      def show
        @oxxo = Spree::Oxxo.find(params[:id])
        @orders = @oxxo.orders
      end

      def destroy
        @oxxo = Spree::Oxxo.find(params[:id])
        if @oxxo.destroy
          flash[:notice] = t('oxxo.delete_order_successful')
        end
        redirect_to admin_oxxos_path
      end

    end
  end
end
