module Spree
  module Admin
    class OxxosController < BaseController

      def index
        @oxxo = Spree::Oxxo.new
      end

      def create
        @order_import = Spree::Oxxo.create(params[:oxxo])
        Delayed::Job.enqueue SpreeOxxo::ImportJob.new(@order_import, current_spree_user)
        flash[:notice] = t('oxxo.processing')
        redirect_to admin_oxxos_path
      end

      def show
        @oxxo = Spree::Oxxo.find(params[:id])
        @orders = @oxxo.orders
      end

    end
  end
end
