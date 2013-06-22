Deface::Override.new(:virtual_path => 'spree/admin/shared/_order_sub_menu',
                     :name => 'oxxo_admin_tab',
                     :insert_bottom => "[data-hook='admin_order_sub_tabs']",
                     :text => "<%= tab :oxxos, :label => t('oxxo.title') %>",
                     :disable => false
                    )

Deface::Override.new(:virtual_path => 'spree/admin/orders/index',
                     :name => 'orders_oxxo_sub_menu',
                     :insert_bottom => "[data-hook='admin_orders_index_search']",
                     :text => "<%= render :partial => 'spree/admin/shared/order_sub_menu' %>",
                     :disable => false
                    )
