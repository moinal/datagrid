require "action_view"

module Datagrid
  module Helper

    def datagrid_format_value(column, asset)
      value = column.value(asset)
      if column.options[:url]
        link_to(value, column.options[:url].call(asset))
      else
        case column.format
        when :url
          link_to(column.label  ? asset.send(column.label) : I18n.t("datagrid.table.url_label", :default => "URL"), value)
        else
          value
        end
      end
    end

    def datagrid_table(report, *args)
      options = args.extract_options!
      html = options[:html] || {}
      html[:class] ||= "datagrid"
      paginate = options[:paginate] || {}
      paginate[:page] ||= params[:page]
      assets = report.assets.paginate(paginate)
      content_tag(:table, html) do
        table = content_tag(:tr, datagrid_header(report, options))
        table << datagrid_rows(report.columns, assets, options)
        table
      end
    end

    protected

    def datagrid_header(grid, options)
      header = empty_string
      grid.columns.each do |column|
        data = column.header.html_safe
        if column.order
          data << datagrid_order_for(grid, column)
        end
        header << content_tag(:th, data)
      end
      header
    end

    def datagrid_rows(columns, assets, options)
      rows = empty_string
      assets.each do |asset|
        rows << content_tag(:tr, :class => cycle("odd", "even")) do
          html = empty_string
          columns.each do |column|
            html << content_tag(:td, datagrid_format_value(column, asset))
          end
          html
        end

      end
      rows
    end

    def datagrid_order_for(grid, column)
      content_tag(:div, :class => "order") do
        link_to(
          I18n.t("datagrid.table.order.asc", :default => "ASC"), url_for(grid.param_name => grid.attributes.merge(:order => column.order))
        ) + " " +
          link_to(I18n.t("datagrid.table.order.desc", :default => "DESC"), url_for(grid.param_name => grid.attributes.merge(:order => column.desc_order)))
      end
    end

    def empty_string
      res = ""
      res.respond_to?(:html_safe) ? res.html_safe : res
    end
  end

  ::ActionView::Base.send(:include, ::Datagrid::Helper)

end
