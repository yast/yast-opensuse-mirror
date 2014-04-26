# Copyright (c) 2014 SUSE LLC.
#  All Rights Reserved.

#  This program is free software; you can redistribute it and/or
#  modify it under the terms of version 2 or 3 of the GNU General
# Public License as published by the Free Software Foundation.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, contact SUSE LLC.

#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.suse.com

require "yast"
require "opensuse_mirror/updates"

module OpensuseMirror
  class MainDialog
    include Yast::UIShortcuts
    include Yast::I18n

    def self.run
      Yast.import "UI"
      dialog = MainDialog.new
      dialog.run
    end

    def initialize
      textdomain "opensuse_mirror"
    end

    def run
      return unless create_dialog

      begin
        return controller_loop
      ensure
        close_dialog
      end
    end

  private
    DEFAULT_SIZE_OPT = Yast::Term.new(:opt, :defaultsize)

    def create_dialog
      Yast::UI.OpenDialog DEFAULT_SIZE_OPT, dialog_content
    end

    def close_dialog
      Yast::UI.CloseDialog
    end

    def controller_loop
      while true do
        input = Yast::UI.UserInput
        case input
        when :cancel
          return :cancel
        when :ok
          return :ok
        when :enable
          switch_state_to true
          redraw_channels
        when :disable
          switch_state_to false
          redraw_channels
        when :all
          toggle_selection
        else
          raise "Unknown action #{input}"
        end
      end
    end

    def selected_updates
      Yast::UI.QueryWidget(Id(:updates_table), :SelectedItems)
    end

    def switch_state_to target_state
      selected_updates.each do |update|
        available_updates.find(update).mirrored = target_state
      end
    end

    def toggle_selection
      all = selected_updates.empty?
      if all
        selection = available_updates.map { |u| Id(u.directory) }
      else
        selection = []
      end
      Yast::UI.ChangeWidget(Id(:updates_table), :SelectedItems, selection)
    end

    def redraw_channels
      Yast::UI.ChangeWidget(:updates_table, :Items, updates_items)
    end

    def dialog_content
      VBox(
        HBox(
          updates_table,
          action_buttons
        ),
        VStretch(),
        Right(ending_buttons)
      )
    end

    def updates_table
      Table(
        Id(:updates_table),
        Opt(:multiSelection),
        Header(_("Directory"), _("Mirrored")),
        updates_items
      )
    end

    def updates_items
      available_updates.map do |update|
        Item(
          Id(update.directory),
          update.directory,
          update.mirrored ? _("yes") : _("no")
        )
      end
    end

    def available_updates
      @available_updates ||= Updates.available
    end

    def ending_buttons
      PushButton(Id(:ok), _("&Exit"))
    end

    def action_buttons
      VBox(
        PushButton(Id(:enable), _("&Mirror")),
        PushButton(Id(:disable), _("&Do not Mirror")),
        PushButton(Id(:all), _("Select/Deselect &All")),
      )
    end
  end
end
