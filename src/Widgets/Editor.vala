/*
 * Copyright (C) 2017 Lains
 * 
 * Modified July 5, 2018
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

using ThiefMD.Controllers;
using Gdk;

namespace ThiefMD.Widgets {
    public class Editor : Gtk.SourceView {
        public static new Gtk.SourceBuffer buffer;
        public static string scroll_text = "";
        public static double cursor_position = 0;
        public bool is_modified { get; set; default = false; }
        private bool should_scroll { get; set; default = false; }
        private bool should_save { get; set; default = false; }
        private bool should_update_preview { get; set; default = false; }
        public File file;
        public GtkSpell.Checker spell = null;
        public Gtk.TextTag warning_tag;
        public Gtk.TextTag error_tag;
        private int last_width = 0;
        private int last_height = 0;
        private bool spellcheck_active;
        private bool typewriter_active;

        public Editor () {
            update_settings ();
            var settings = AppSettings.get_default ();
            settings.changed.connect (update_settings);

            try {
                string text;
                var file = File.new_for_path (settings.last_file);

                if ((settings.last_file != null) &&
                    (settings.last_file != "") &&
                    file.query_exists ())
                {
                    string filename = file.get_path ();
                    GLib.FileUtils.get_contents (filename, out text);
                    set_text (text, true);
                    editable = true;
                } else {
                    set_text (Constants.FIRST_USE, true);
                    editable = false;
                }
            } catch (Error e) {
                warning ("Error: %s\n", e.message);
            }

            this.populate_popup.connect ((source, menu) => {
                Gtk.MenuItem menu_insert_datetime = new Gtk.MenuItem.with_label (_("Insert Datetime"));
                menu_insert_datetime.activate.connect (() => {
                    DateTime now = new DateTime.now_local ();
                    string new_text = now.format ("%F %H:%M");
                    insert_at_cursor (new_text);
                });

                Gtk.MenuItem menu_insert_frontmatter = new Gtk.MenuItem.with_label (_("Insert YAML Frontmatter"));
                menu_insert_frontmatter.activate.connect (() => {
                    if (!buffer.text.has_prefix ("---")) {
                        var settings_menu = AppSettings.get_default ();
                        int new_cursor_location = 0;
                        File current_file = File.new_for_path (settings_menu.last_file);
                        Regex date = null;
                        try {
                            date = new Regex ("([0-9]{4}-[0-9]{1,2}-[0-9]{1,2}-?)?(.*?)$", RegexCompileFlags.MULTILINE | RegexCompileFlags.CASELESS, 0);
                        } catch (Error e) {
                            warning ("Could not compile regex: %s", e.message);
                        }

                        DateTime now = new DateTime.now_local ();
                        string current_time = now.format ("%F %H:%M");

                        string parent_folder = current_file.get_parent ().get_basename ().down ();
                        string page_type = (parent_folder.contains ("post") || parent_folder.contains ("draft")) ? "post" : "page";
                        string current_title = current_file.get_basename ();
                        current_title = current_title.substring (0, current_title.last_index_of ("."));

                        // Attempt to convert the file name into a title for the post
                        try {
                            if (date != null) {
                                current_title = date.replace_eval (
                                    current_title,
                                    (ssize_t) current_title.length,
                                    0,
                                    RegexMatchFlags.NOTEMPTY,
                                    (match_info, result) =>
                                    {
                                        result.append (match_info.fetch (match_info.get_match_count () - 1));
                                        return false;
                                    }
                                );
                            }
                        } catch (Error e) {
                            warning ("Could not generate title");
                        }

                        current_title = current_title.replace ("_", " ");
                        current_title = current_title.replace ("-", " ");
                        string [] parts = current_title.split (" ");
                        if (parts != null && parts.length != 0) {
                            current_title = "";
                            foreach (var part in parts) {
                                part = part.substring (0, 1).up () + part.substring (1).down ();
                                current_title += part + " ";
                            }
                            current_title = current_title.chomp ();
                        }

                        // Build the front matter
                        string frontmatter = "---\n";
                        frontmatter += "layout: " + page_type + "\n";
                        frontmatter += "title: ";
                        new_cursor_location = frontmatter.length;
                        frontmatter += current_title + "\n";
                        // Only insert datetime if we think it's a post
                        if (page_type == "post") {
                            frontmatter += "date: " + current_time + "\n";
                        }
                        frontmatter += "---\n";

                        // Place the text
                        buffer.text = frontmatter + buffer.text;

                        // Move the cursor to select the title
                        Gtk.TextIter start, end;
                        buffer.get_bounds(out start, out end);
                        start.forward_chars (new_cursor_location);
                        end = start;
                        end.forward_line ();
                        end.backward_char ();
                        buffer.place_cursor (start);
                        buffer.select_range (start, end);

                        // Move the frontmatter onscreen
                        should_scroll = true;
                        move_typewriter_scolling ();
                    }
                });

                menu.append (menu_insert_datetime);
                menu.append (menu_insert_frontmatter);
                menu.show_all ();

                menu.selection_done.connect (() => {
                    var selected = get_selected (menu);

                    if (selected != null) {
                        try {
                            spell.set_language (selected.label);
                            settings.spellcheck_language = selected.label;
                        } catch (Error e) {
                        }
                    }
                });
            });
        }

        construct {
            var settings = AppSettings.get_default ();

            buffer = new Gtk.SourceBuffer.with_language (UI.get_source_language ());
            buffer.highlight_syntax = true;
            buffer.set_max_undo_levels (20);
            buffer.changed.connect (() => {
                is_modified = true;
                on_text_modified ();
            });

            warning_tag = new Gtk.TextTag ("warning_bg");
            warning_tag.underline = Pango.Underline.ERROR;
            warning_tag.underline_rgba = Gdk.RGBA () { red = 0.13, green = 0.55, blue = 0.13, alpha = 1.0 };

            error_tag = new Gtk.TextTag ("error_bg");
            error_tag.underline = Pango.Underline.ERROR;

            buffer.tag_table.add (error_tag);
            buffer.tag_table.add (warning_tag);

            is_modified = false;

            if (settings.autosave == true) {
                Timeout.add (10000, autosave);
            }

            //
            // Register for redrawing of window for handling margins and other
            // redrawing
            //
            size_allocate.connect (() => {
                dynamic_margins();
            });

            this.set_buffer (buffer);
            this.set_wrap_mode (Gtk.WrapMode.WORD_CHAR);
            this.top_margin = Constants.TOP_MARGIN;
            this.bottom_margin = Constants.BOTTOM_MARGIN;
            this.expand = true;
            this.has_focus = true;
            this.set_tab_width (4);
            this.set_insert_spaces_instead_of_tabs (true);
            set_scheme (settings.get_valid_theme_id ());
            spell = new GtkSpell.Checker ();

            if (settings.spellcheck) {
                debug ("Activate spellcheck\n");
                spell.attach (this);
                spellcheck_active = true;
            } else {
                debug ("Disable spellcheck\n");
                spellcheck_active = false;
            }

            typewriter_active = settings.typewriter_scrolling;
            if (typewriter_active) {
                Timeout.add(500, move_typewriter_scolling);
            }
            last_width = settings.window_width;
            last_height = settings.window_height;
            show_all ();
        }

        public signal void changed ();

        public bool spellcheck {
            set {
                if (value && !spellcheck_active) {
                    debug ("Activate spellcheck\n");
                    try {
                        var settings = AppSettings.get_default ();
                        var last_language = settings.spellcheck_language;
                        bool language_set = false;
                        var language_list = GtkSpell.Checker.get_language_list ();
                        foreach (var element in language_list) {
                            if (last_language == element) {
                                language_set = true;
                                spell.set_language (last_language);
                                break;
                            }
                        }

                        if (language_list.length () == 0) {
                            spell.set_language (null);
                        } else if (!language_set) {
                            last_language = language_list.first ().data;
                            spell.set_language (last_language);
                        }
                        spell.attach (this);
                        spellcheck_active = true;
                    } catch (Error e) {
                        warning (e.message);
                    }
                } else if (!value && spellcheck_active) {
                    debug ("Disable spellcheck\n");
                    spell.detach ();
                    spellcheck_active = false;
                }
            }
        }

        private bool autosave () {
            var settings = AppSettings.get_default ();

            //
            // Make sure we're not swapping files
            //
            if (should_save) {
                FileManager.save_work_file ();
                should_save = false;
            }

            // Jamming this here for now to prevent
            // reinit of spellcheck on resize
            int w, h;
            ThiefApp.get_instance ().main_window.get_size (out w, out h);
            settings.window_width = w;
            settings.window_height = h;

            if (spellcheck_active) {
                spell.recheck_all ();
            }

            return settings.autosave;
        }

        private Gtk.MenuItem? get_selected (Gtk.Menu? menu) {
            if (menu == null) return null;
            var active = menu.get_active () as Gtk.MenuItem;

            if (active == null) return null;
            var sub_menu = active.get_submenu () as Gtk.Menu;
            if (sub_menu != null) {
                return sub_menu.get_active () as Gtk.MenuItem;
            }

            return null;
        }

        public void on_text_modified () {
            if (FileManager.is_file_open ()) {
                editable = true;
            }

            should_scroll = true;

            // Mark as we should save the file
            // If no autosave, schedule a save.
            if (!should_save) {
                var settings = AppSettings.get_default ();
                if (!settings.autosave) {
                    Timeout.add (3000, autosave);
                }
                should_save = true;
            }

            if (is_modified) {
                changed ();
                is_modified = false;
            }

            // Move the preview if present
            if (!should_update_preview) {
                Timeout.add (500, update_preview);
                should_update_preview = true;
            }
        }

        public bool update_preview () {
            var cursor = buffer.get_insert ();
            if (cursor != null) {
                Gtk.TextIter cursor_iter;
                Gtk.TextIter start, end;
                buffer.get_bounds (out start, out end);

                buffer.get_iter_at_mark (out cursor_iter, cursor);
                buffer.get_iter_at_mark (out cursor_iter, cursor);;
                //  scroll_text = buffer.get_text (start, cursor_iter, true);
                //  scroll_text += "<span id='thiefmark'></span>";
                //  scroll_text += buffer.get_text (cursor_iter, end, true);
                string before = buffer.get_text (start, cursor_iter, true);
                string last_line = before.substring (before.last_index_of ("\n") + 1);
                string after = buffer.get_text (cursor_iter, end, true);
                int nl_loc = after.index_of ("\n");
                string first_line = after;
                if (nl_loc != -1) {
                    first_line = after.substring (0, nl_loc);
                }
                int adjustment = get_scrollmark_adjustment (last_line, first_line);
                adjustment = skip_special_chars (after, adjustment);
                scroll_text = before;
                scroll_text += after.substring (0, adjustment);
                scroll_text += ThiefProperties.THIEF_MARK_CONST;
                scroll_text += after.substring (adjustment);

                Preview.update_view ();
            }

            should_update_preview = false;
            return false;
        }

        private int skip_special_chars (string haystack, int index = 0) {
            const string special_chars = "#>*`-+ ";

            while (haystack.length != 0 && special_chars.contains (haystack.substring (index, 1)) && index < haystack.length - 2) {
                index++;
            }

            return index;
        }

        private int get_scrollmark_adjustment (string before, string after) {
            int open_p = before.last_index_of ("(");
            int open_t = before.last_index_of ("<");
            int close_p = before.last_index_of (")");
            int close_t = before.last_index_of (">");

            if (open_p == -1 && open_t == -1) {
                return 0;
            }

            if (open_p > close_p && open_t > close_t) {
                close_p = after.index_of (")");
                close_t = after.index_of (">");
                return int.max(close_p, close_t) + 1;
            }

            if (open_p > close_p) {
                close_p = after.index_of (")");
                return close_p + 1;
            }

            if (open_t > close_t) {
                close_t = after.index_of (")");
                return close_t + 1;
            }

            return 0;
        }

        public void set_text (string text, bool opening = true) {
            if (opening) {
                buffer.begin_not_undoable_action ();
                buffer.changed.disconnect (on_text_modified);
            }

            buffer.text = text;

            if (opening) {
                buffer.end_not_undoable_action ();
                buffer.changed.connect (on_text_modified);
            }

            Gtk.TextIter? start = null;
            buffer.get_start_iter (out start);
            buffer.place_cursor (start);
        }

        public void dynamic_margins () {
            var settings = AppSettings.get_default ();

            if (!ThiefApp.get_instance ().ready) {
                return;
            }

            int w, h, m, p;
            ThiefApp.get_instance ().main_window.get_size (out w, out h);

            w = w - ThiefApp.get_instance ().pane_position;
            last_height = h;

            if (w == last_width) {
                return;
            }

            last_width = w;

            // If ThiefMD is Full Screen, add additional padding
            p = (settings.fullscreen) ? 5 : 0;

            var margins = settings.margins;
            switch (margins) {
                case Constants.NARROW_MARGIN:
                    m = (int)(w * ((Constants.NARROW_MARGIN + p) / 100.0));
                    break;
                case Constants.WIDE_MARGIN:
                    m = (int)(w * ((Constants.WIDE_MARGIN + p) / 100.0));
                    break;
                default:
                case Constants.MEDIUM_MARGIN:
                    m = (int)(w * ((Constants.MEDIUM_MARGIN + p) / 100.0));
                    break;
            }

            // Update margins
            left_margin = m;
            right_margin = m;

            typewriter_scrolling ();

            // Keep the curson in view?
            should_scroll = true;
            move_typewriter_scolling ();
        }

        private void typewriter_scrolling () {
            var settings = AppSettings.get_default ();

            // Check for typewriter scrolling and adjust bottom margin to
            // compensate
            if (settings.typewriter_scrolling) {
                bottom_margin = (int)(last_height * (1 - Constants.TYPEWRITER_POSITION)) - 20;
                top_margin = (int)(last_height * Constants.TYPEWRITER_POSITION) - 20;
            } else {
                bottom_margin = Constants.BOTTOM_MARGIN;
                top_margin = Constants.TOP_MARGIN;
            }
        }

        private void update_settings () {
            var settings = AppSettings.get_default ();
            this.set_pixels_above_lines(settings.spacing);
            this.set_pixels_inside_wrap(settings.spacing);
            this.set_show_line_numbers (settings.show_num_lines);

            typewriter_scrolling ();
            if (!typewriter_active && settings.typewriter_scrolling) {
                typewriter_active = true;
                Timeout.add(500, move_typewriter_scolling);
                queue_draw ();
                should_scroll = true;
                move_typewriter_scolling ();
            } else if (typewriter_active && !settings.typewriter_scrolling) {
                typewriter_active = false;
                queue_draw ();
                should_scroll = true;
                move_typewriter_scolling ();
            }

            set_scheme (settings.get_valid_theme_id ());

            spellcheck_enable();
        }

        private void spellcheck_enable () {
            var settings = AppSettings.get_default ();
            spellcheck = settings.spellcheck;
        }

        public void set_scheme (string id) {
            if (id == "thiefmd") {
                // Reset application CSS to coded
                get_default_scheme ();
                var style_manager = Gtk.SourceStyleSchemeManager.get_default ();
                var style = style_manager.get_scheme (id);
                buffer.set_style_scheme (style);
            } else {
                UI.UserSchemes ().force_rescan ();
                var style = UI.UserSchemes ().get_scheme (id);
                buffer.set_style_scheme (style);
            }
        }

        private string get_default_scheme () {
            var provider = new Gtk.CssProvider ();
            provider.load_from_resource ("/com/github/kmwallio/thiefmd/app-stylesheet.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = false;
            Gtk.TextIter start, end;
            buffer.get_bounds (out start, out end);
            return "thiefmd";
        }

        public bool move_typewriter_scolling () {
            var settings = AppSettings.get_default ();
            var cursor = buffer.get_insert ();

            if (should_scroll && !UI.moving ()) {
                this.scroll_to_mark(cursor, 0.0, true, 0.0, Constants.TYPEWRITER_POSITION);
                should_scroll = false;
            }

            return settings.typewriter_scrolling;
        }
    }
}
