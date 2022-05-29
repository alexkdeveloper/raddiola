
using Gtk;
using Gst;

namespace Raddiola {

    public class MainWindow : Gtk.ApplicationWindow {

private Stack stack;
private Box vbox_player_page;
private Box vbox_edit_page;
private dynamic Element player;
private Gtk.ListStore list_store;
private TreeView tree_view;
private GLib.List<string> list;
private Entry entry_name;
private Entry entry_url;
private Button back_button;
private Button add_button;
private Button delete_button;
private Button edit_button;
private Button play_button;
private Button stop_button;
private Button record_button;
private Button stop_record_button;
private Recorder recorder;
private string directory_path;
private string item;
private int mode;

        public MainWindow(Gtk.Application application) {
            GLib.Object(application: application,
                         title: _("Raddiola"),
                         window_position: WindowPosition.CENTER,
                         resizable: true,
                         height_request: 500,
                         width_request: 500,
                         border_width: 10);
        }

        construct {
        Gtk.HeaderBar headerbar = new Gtk.HeaderBar();
        get_style_context().add_class("rounded");
        headerbar.get_style_context().add_class(Gtk.STYLE_CLASS_FLAT);
        headerbar.show_close_button = true;
        set_titlebar(headerbar);
        back_button = new Gtk.Button ();
            back_button.set_image (new Gtk.Image.from_icon_name ("go-previous", Gtk.IconSize.SMALL_TOOLBAR));
            back_button.vexpand = false;
        add_button = new Gtk.Button ();
            add_button.set_image (new Gtk.Image.from_icon_name ("list-add", Gtk.IconSize.SMALL_TOOLBAR));
            add_button.vexpand = false;
        delete_button = new Gtk.Button ();
            delete_button.set_image (new Gtk.Image.from_icon_name ("list-remove", Gtk.IconSize.SMALL_TOOLBAR));
            delete_button.vexpand = false;
        edit_button = new Gtk.Button ();
            edit_button.set_image (new Gtk.Image.from_icon_name ("edit", Gtk.IconSize.SMALL_TOOLBAR));
            edit_button.vexpand = false;
        play_button = new Gtk.Button();
            play_button.set_image (new Gtk.Image.from_icon_name ("media-playback-start", Gtk.IconSize.SMALL_TOOLBAR));
            play_button.vexpand = false;
        stop_button = new Gtk.Button();
            stop_button.set_image (new Gtk.Image.from_icon_name ("media-playback-stop", Gtk.IconSize.SMALL_TOOLBAR));
            stop_button.vexpand = false;
        record_button = new Gtk.Button();
             record_button.set_image (new Gtk.Image.from_icon_name ("media-record", Gtk.IconSize.SMALL_TOOLBAR));
             record_button.vexpand = false;
        stop_record_button = new Gtk.Button();
             stop_record_button.set_image (new Gtk.Image.from_icon_name ("process-stop", Gtk.IconSize.SMALL_TOOLBAR));
             stop_record_button.vexpand = false;
        var open_directory_button = new Gtk.Button();
             open_directory_button.set_image (new Gtk.Image.from_icon_name ("folder-open", Gtk.IconSize.SMALL_TOOLBAR));
             open_directory_button.vexpand = false;
        back_button.set_tooltip_text(_("Back"));
        add_button.set_tooltip_text(_("Add station"));
        delete_button.set_tooltip_text(_("Delete station"));
        edit_button.set_tooltip_text(_("Edit station"));
        play_button.set_tooltip_text(_("Play"));
        stop_button.set_tooltip_text(_("Stop"));
        record_button.set_tooltip_text("Start recording");
        stop_record_button.set_tooltip_text("Stop recording");
        open_directory_button.set_tooltip_text("Open the Records folder");
        back_button.clicked.connect(on_back_clicked);
        add_button.clicked.connect(on_add_clicked);
        delete_button.clicked.connect(on_delete_dialog);
        edit_button.clicked.connect(on_edit_clicked);
        record_button.clicked.connect(on_record_clicked);
        stop_record_button.clicked.connect(on_stop_record_clicked);
        open_directory_button.clicked.connect(on_open_directory_clicked);
        play_button.clicked.connect(on_play_station);
        stop_button.clicked.connect(on_stop_station);
        headerbar.pack_start(back_button);
        headerbar.pack_start(add_button);
        headerbar.pack_start(delete_button);
        headerbar.pack_start(edit_button);
        headerbar.pack_end(open_directory_button);
        headerbar.pack_end(record_button);
        headerbar.pack_end(stop_record_button);
        headerbar.pack_end(stop_button);
        headerbar.pack_end(play_button);
        set_widget_visible(back_button,false);
        set_widget_visible(stop_record_button, false);
        set_widget_visible(stop_button,false);
          stack = new Stack();
          stack.set_transition_duration (600);
          stack.set_transition_type (StackTransitionType.SLIDE_LEFT_RIGHT);
          add (stack);
   list_store = new Gtk.ListStore(Columns.N_COLUMNS, typeof(string));
           tree_view = new TreeView.with_model(list_store);
           var text = new CellRendererText ();
           var column = new TreeViewColumn ();
           column.pack_start (text, true);
           column.add_attribute (text, "markup", Columns.TEXT);
           tree_view.append_column (column);
           tree_view.set_headers_visible (false);
           tree_view.cursor_changed.connect(on_select_item);
   var scroll = new ScrolledWindow (null, null);
        scroll.set_policy (PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
        scroll.add (this.tree_view);
   vbox_player_page = new Box(Orientation.VERTICAL,20);
   vbox_player_page.pack_start(scroll,true,true,0);
   stack.add(vbox_player_page);
        entry_name = new Entry();
        entry_name.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
        entry_name.icon_press.connect ((pos, event) => {
        if (pos == Gtk.EntryIconPosition.SECONDARY) {
              entry_name.set_text("");
              entry_name.grab_focus();
           }
        });
        var label_name = new Label.with_mnemonic (_("_Name:"));
        label_name.set_xalign(0);
        var vbox_name = new Box (Orientation.VERTICAL, 5);
        vbox_name.pack_start (label_name, false, true, 0);
        vbox_name.pack_start (entry_name, true, true, 0);
        entry_url = new Entry();
        entry_url.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY, "edit-clear-symbolic");
        entry_url.icon_press.connect ((pos, event) => {
        if (pos == Gtk.EntryIconPosition.SECONDARY) {
              entry_url.set_text("");
              entry_url.grab_focus();
           }
        });
        var label_url = new Label.with_mnemonic (_("_URL:"));
        label_url.set_xalign(0);
        var vbox_url = new Box (Orientation.VERTICAL, 5);
        vbox_url.pack_start (label_url, false, true, 0);
        vbox_url.pack_start (entry_url, true, true, 0);
        var button_ok = new Button.with_label(_("OK"));
        button_ok.clicked.connect(on_ok_clicked);
        vbox_edit_page = new Box(Orientation.VERTICAL,10);
        vbox_edit_page.pack_start(vbox_name,false,true,0);
        vbox_edit_page.pack_start(vbox_url,false,true,0);
        vbox_edit_page.pack_start(button_ok,false,true,0);
        stack.add(vbox_edit_page);
        stack.visible_child = vbox_player_page;
        player = ElementFactory.make ("playbin", "play");
   directory_path = Environment.get_user_data_dir()+"/.stations_for_radio_app";
   GLib.File file = GLib.File.new_for_path(directory_path);
   if(!file.query_exists()){
     try{
        file.make_directory();
     }catch(Error e){
        stderr.printf (_("Error: %s") + "\n", e.message);
     }
     create_default_stations();
   }
   show_stations();
   recorder = Recorder.get_default ();
   record_button.set_sensitive(false);
 }

   private void on_play_station(){
         var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert(_("Please choose a station"));
               return;
           }
      string uri;
        try {
            FileUtils.get_contents (directory_path+"/"+item, out uri);
        } catch (Error e) {
            alert(e.message);
            return;
        }
      player.uri = uri;
      player.set_state (State.PLAYING);
      set_widget_visible(play_button,false);
      set_widget_visible(stop_button,true);
      record_button.set_sensitive(true);
   }

   private void on_stop_station(){
      player.set_state (State.READY);
      set_widget_visible(play_button,true);
      set_widget_visible(stop_button,false);
      if(recorder.is_recording){
          on_stop_record_clicked();
      }
      record_button.set_sensitive(false);
   }

   private void on_record_clicked(){
    var selection = tree_view.get_selection();
    selection.set_mode(SelectionMode.SINGLE);
    TreeModel model;
    TreeIter iter;
    if (!selection.get_selected(out model, out iter)) {
        alert(_("Please choose a station"));
        return;
    }
    try {
        recorder.start_recording();
      } catch (Gst.ParseError e) {
         alert(e.message);
         return;
      }
      set_widget_visible(record_button,false);
      set_widget_visible(stop_record_button,true);
   }

   private void on_stop_record_clicked(){
        recorder.stop_recording();
        set_widget_visible(record_button,true);
        set_widget_visible(stop_record_button,false);
   }

   private void on_open_directory_clicked(){
       try {
         Gtk.show_uri_on_window(this, "file://"+Environment.get_user_data_dir(), Gdk.CURRENT_TIME);
       } catch (Error e) {
           alert(e.message);
       }      
   }

   private void on_select_item () {
           var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               return;
           }
           TreePath path = model.get_path(iter);
           var index = int.parse(path.to_string());
           if (index >= 0) {
               item = list.nth_data(index);
               recorder.station_name = item;
           }
       }

   private void on_add_clicked () {
              stack.visible_child = vbox_edit_page;
              set_buttons_on_edit_page();
              mode = 1;
              if(!is_empty(entry_name.get_text())){
                    entry_name.set_text("");
              }
              if(!is_empty(entry_url.get_text())){
                    entry_url.set_text("");
              }
  }

   private void on_edit_clicked(){
         var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert(_("Please choose a station"));
               return;
           }
        stack.visible_child = vbox_edit_page;
        set_buttons_on_edit_page();
        mode = 0;
        entry_name.set_text(item);
        string url;
        try {
            FileUtils.get_contents (directory_path+"/"+item, out url);
        } catch (Error e) {
            stderr.printf (_("Error: %s") + "\n", e.message);
        }
        entry_url.set_text(url);
   }

   private void on_ok_clicked(){
         if(is_empty(entry_name.get_text())){
		    alert(_("Please enter the name"));
                    entry_name.grab_focus();
                    return;
		}
		if(is_empty(entry_url.get_text())){
		   alert(_("Please enter the url"));
                   entry_url.grab_focus();
                   return;
		}
        switch(mode){
            case 0:
		GLib.File select_file = GLib.File.new_for_path(directory_path+"/"+item);
		GLib.File edit_file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip());
		if (select_file.get_basename() != edit_file.get_basename() && !edit_file.query_exists()){
                FileUtils.rename(select_file.get_path(), edit_file.get_path());
                if(!edit_file.query_exists()){
                    alert(_("Rename failed"));
                    return;
                }
                try {
                 FileUtils.set_contents (edit_file.get_path(), entry_url.get_text().strip());
              } catch (Error e) {
                     stderr.printf (_("Error: %s") + "\n", e.message);
            }
            }else{
                if (select_file.get_basename() != edit_file.get_basename()) {
                    alert(_("A station with the same name already exists"));
                    entry_name.grab_focus();
                    return;
                }
                try {
                 FileUtils.set_contents (edit_file.get_path(), entry_url.get_text().strip());
              } catch (Error e) {
                     stderr.printf (_("Error: %s") + "\n", e.message);
             }
            }
            show_stations();
            break;
            case 1:
	GLib.File file = GLib.File.new_for_path(directory_path+"/"+entry_name.get_text().strip());
        if(file.query_exists()){
            alert(_("A station with the same name already exists"));
            entry_name.grab_focus();
            return;
        }
        try {
            FileUtils.set_contents (file.get_path(), entry_url.get_text().strip());
        } catch (Error e) {
            stderr.printf (_("Error: %s") + "\n", e.message);
        }
        if(!file.query_exists()){
           alert(_("Add failed"));
           return;
        }else{
           show_stations();
        }
        break;
      }
      on_back_clicked();
   }

   private void on_back_clicked(){
       stack.visible_child = vbox_player_page;
       set_buttons_on_player_page();
   }

   private void on_delete_dialog(){
       var selection = tree_view.get_selection();
           selection.set_mode(SelectionMode.SINGLE);
           TreeModel model;
           TreeIter iter;
           if (!selection.get_selected(out model, out iter)) {
               alert(_("Please choose a station"));
               return;
           }
           GLib.File file = GLib.File.new_for_path(directory_path+"/"+item);

      var dialog_delete_station = new Granite.MessageDialog.with_image_from_icon_name (_("Question"), _("Delete station %s ?").printf (file.get_basename ()), "dialog-question", Gtk.ButtonsType.NONE);
      dialog_delete_station.add_button (_("No"), 0);
      dialog_delete_station.add_button (_("Delete"), 1);
      dialog_delete_station.show_all ();
      int result = dialog_delete_station.run ();
      switch (result) {
          case 0:
              dialog_delete_station.destroy ();
              break;
          case 1:
              FileUtils.remove (directory_path+"/"+item);
         if(file.query_exists()){
            alert(_("Delete failed"));
         }else{
             show_stations();
         }
              dialog_delete_station.destroy ();
              break;
      }
   }

   private void show_stations () {
           list_store.clear();
           list = new GLib.List<string> ();
            try {
            Dir dir = Dir.open (directory_path, 0);
            string? name = null;
            while ((name = dir.read_name ()) != null) {
                list.append(name);
            }
        } catch (FileError err) {
            stderr.printf (err.message);
        }
         TreeIter iter;
           foreach (string item in list) {
               list_store.append(out iter);
               list_store.set(iter, Columns.TEXT, item);
           }
       }

   private void set_widget_visible (Gtk.Widget widget, bool visible) {
         widget.no_show_all = !visible;
         widget.visible = visible;
  }

   private void set_buttons_on_player_page(){
       set_widget_visible(back_button,false);
       set_widget_visible(add_button,true);
       set_widget_visible(delete_button,true);
       set_widget_visible(edit_button,true);
   }

   private void set_buttons_on_edit_page(){
       set_widget_visible(back_button,true);
       set_widget_visible(add_button,false);
       set_widget_visible(delete_button,false);
       set_widget_visible(edit_button,false);
   }

   private bool is_empty(string str){
        return str.strip().length == 0;
      }

       private enum Columns {
           TEXT, N_COLUMNS
       }
   private void create_default_stations(){
          string[] name_station = {"NonStopPlay","Classical Music","Fip Radio","Jazz Legends","Joy Radio","Live-icy","Music Radio","Radio Electron","Dubstep","Trancemission","Karadeniz Akustik"};
          string[] url_station = {"http://stream.nonstopplay.co.uk/nsp-128k-mp3","http://stream.srg-ssr.ch/m/rsc_de/mp3_128","http://direct.fipradio.fr/live/fip-midfi.mp3","http://jazz128legends.streamr.ru/","http://airtime.joyradio.cc:8000/airtime_192.mp3","http://live-icy.gss.dr.dk:8000/A/A05H.mp3","http://ice-the.musicradio.com/CapitalXTRANationalMP3","http://radio-electron.ru:8000/128","http://air.radiorecord.ru:8102/dub_320","http://air.radiorecord.ru:8102/tm_320","https://karadenizakustik.radyotvonline.net"};
          for(int i=0;i<10;i++){
            try {
                 FileUtils.set_contents (directory_path+"/"+name_station[i], url_station[i]);
              } catch (Error e) {
                     stderr.printf (_("Error: %s") + "\n", e.message);
             }
          }
   }
   private void alert (string str){
          var dialog = new Granite.MessageDialog.with_image_from_icon_name (_("Message"), str, "dialog-warning");
        dialog.show_all ();
        dialog.run ();
        dialog.destroy ();
       }
   }
}
