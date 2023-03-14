using Gtk;
using WebKit;
using Notify;

namespace MyWhatsAppWeb {

	public class MyWhatsAppWebDataManager: WebsiteDataManager {

		public MyWhatsAppWebDataManager(string base_path) {
			Object(disk_cache_directory: base_path + "/disk/",
				local_storage_directory: base_path + "/data/" , 
				offline_application_cache_directory: base_path + "/cache/",
				indexeddb_directory: base_path + "/database/"
			);
		}
	}
	
	public class MyWhatsAppWebApp : Window {
	
		private static string ICON_NAME = "mywhatsappweb.png";
		private static string SITE_URL="https://web.whatsapp.com";
		private static string DATA_DIR="${HOME}/.local/share/mywhatsappweb/${session_name}";

		private string current_data_dir = null;
		private string session_name = null;
		private bool incognito = false;
		private string icon = null;

		private Gtk.StatusIcon tray = null;
		private WebKit.WebView web_view = null;

		public MyWhatsAppWebApp(string session_name, bool incognito) {
			this.session_name = session_name;
			this.incognito = incognito;
			Notify.init ("MyWhatsAppWeb");
			// check data structure
			this.current_data_dir = DATA_DIR.replace("~",Environment.get_home_dir())
					.replace("${HOME}",Environment.get_home_dir())
					.replace("${session_name}",this.session_name);
			this.search_icon();
			if (!this.incognito)
				this.create_struct();
			this.init();
		}

		private void search_icon() {
			this.icon = "${HOME}/.local/share/icons/".replace("~",Environment.get_home_dir())
			.replace("${HOME}",Environment.get_home_dir()) + ICON_NAME;
			File file = File.new_for_path(this.icon);
			if (!file.query_exists()) {
				this.icon = "/usr/share/icons/" + ICON_NAME;
				file = File.new_for_path(this.icon);
				if (!file.query_exists()) {
					this.icon = "mywhatsappweb";
				}
			}
		}

		private WebView create_webview() {
			WebView web_view = null;
			if (!this.incognito) {
				string c_file = this.current_data_dir + "/cookies.txt";
				WebsiteDataManager data_manager = new MyWhatsAppWebDataManager(this.current_data_dir);
				WebContext context = new WebContext.with_website_data_manager(data_manager);
				web_view = new WebKit.WebView.with_context(context);
				web_view.get_website_data_manager().get_cookie_manager().set_persistent_storage(c_file, CookiePersistentStorage.TEXT);
				web_view.get_website_data_manager().get_cookie_manager().set_accept_policy(CookieAcceptPolicy.NO_THIRD_PARTY);
			} else {
				WebContext context = new WebContext.ephemeral();
				web_view =  new WebKit.WebView.with_context(context);
				web_view.get_website_data_manager().get_cookie_manager().set_accept_policy(CookieAcceptPolicy.NEVER);
			}
			WebKit.Settings settings = web_view.get_settings();
			settings.enable_javascript = true;
			settings.enable_page_cache = false;
			settings.enable_offline_web_application_cache = false;
			settings.user_agent = "MyWhatsAppWeb";
			List<SecurityOrigin> site_notification = new List<SecurityOrigin>();
			site_notification.append(new SecurityOrigin.for_uri(SITE_URL));
			web_view.get_context().init_notification_permissions(site_notification,new List<SecurityOrigin>());
			println("Disk cache directory: " + web_view.get_website_data_manager().get_disk_cache_directory());
			println("IndexDB directory: " + web_view.get_website_data_manager().get_indexeddb_directory());
			println("Local storage: " + web_view.get_website_data_manager().get_local_storage_directory());
			println("Offline cache app dir: " + web_view.get_website_data_manager().get_offline_application_cache_directory());
			// menu
			web_view.context_menu.connect((source,menu, event, hit) => { 
				menu.remove_all(); 
				SimpleAction actionReload = new SimpleAction("reload",null);
				actionReload.activate.connect(() => {source.reload();});
				ContextMenuItem itemReload = new WebKit.ContextMenuItem.from_gaction(actionReload,"Reload",null);
				menu.append(itemReload);
				SimpleAction actionReloadCache = new SimpleAction("reload-cache",null);
				actionReloadCache.activate.connect(() => {source.reload_bypass_cache();});
				ContextMenuItem itemReloadCache = new WebKit.ContextMenuItem.from_gaction(actionReloadCache,"Reload (ignore cache)",null);
				menu.append(itemReloadCache);
				SimpleAction actionDeleteCache = new SimpleAction("reload-delete",null);
				actionDeleteCache.activate.connect(() => { 
					source.load_plain_text("Delete the cache and reload");
					source.get_context().get_website_data_manager().clear(WebsiteDataTypes.ALL,0,null);
					source.load_uri(SITE_URL);
				});
				ContextMenuItem itemDelete = new WebKit.ContextMenuItem.from_gaction(actionDeleteCache,"Delete cache and reload",null);
				menu.append(itemDelete);
				return false;
			});
			web_view.show_notification.connect((source,notification) => {
				try {
					Notify.Notification n = new Notify.Notification ("%s - %s".printf(notification.title, this.session_name), notification.body, this.icon);
					n.show ();
				} catch (Error e) {
					error("Error: %s",e.message);
				}
				return true;
			});
			web_view.load_uri(SITE_URL);
			return web_view;
		}

		private Gtk.Box create_box() {
			Gtk.Box box = new Gtk.Box(Gtk.Orientation.VERTICAL,0);
			box.pack_start (this.web_view, true, true, 0);
			return box;
		}

		private void create_window(Gtk.Box box) {
			this.set_title("MyWhatsAppWeb%s%s".printf((this.incognito?" - Private":""),(this.session_name!="")?" (%s)".printf(this.session_name):""));
			this.set_default_size (800, 600);
			this.add(box);
			this.destroy.connect (this.exit);
		}

		private void init() {
			// Create WebView
			this.web_view = this.create_webview();
			this.web_view.show_all();
			// Create Container 
			Gtk.Box box = this.create_box();
			box.show_all();
			// Create window
			this.create_window(box);
			// create tray
			this.create_tray();
			this.set_icon_from_file(this.icon);
			this.show_all();
		}

		private void create_tray() {
			this.tray = new StatusIcon.from_file(this.icon);
			this.tray.set_tooltip_text("MyWhatsAppWeb");
			this.tray.set_visible(true);
			Gtk.Menu menu = new Gtk.Menu();
			Gtk.MenuItem menuItem = new Gtk.MenuItem.with_label("Show");
			menuItem.activate.connect(() => { this.from_tray(); });
			menu.append(menuItem);
			menuItem = new Gtk.MenuItem.with_label("Hide");
			menuItem.activate.connect(() => { this.to_tray(); });
			menu.append(menuItem);
			menuItem = new Gtk.MenuItem.with_label("Quit");
			menuItem.activate.connect(() => { this.exit(); });
			menu.append(menuItem);
			menu.show_all();
			this.tray.activate.connect(() => {this.from_tray(); });
			this.tray.popup_menu.connect(() => { menu.popup_at_pointer(); });
		}

		public void to_tray() { this.hide(); }
		public void from_tray() { this.show_all(); }

		public void exit() { Gtk.main_quit(); }

		private void create_struct() {
			try {
				File folder = File.new_for_path(this.current_data_dir + "/");
				if (!folder.query_exists())
					folder.make_directory_with_parents();
				folder = File.new_for_path(this.current_data_dir+"/data/");
				if (!folder.query_exists())
					folder.make_directory_with_parents();
				folder = File.new_for_path(this.current_data_dir+"/disk/");
				if (!folder.query_exists())
					folder.make_directory_with_parents();
					folder = File.new_for_path(this.current_data_dir+"/cache/");
					if (!folder.query_exists())
						folder.make_directory_with_parents();
					folder = File.new_for_path(this.current_data_dir+"/database/");
					if (!folder.query_exists())
						folder.make_directory_with_parents();			
			} catch (Error e) {
				error("Error creating data structure for %s:\n%s",this.current_data_dir, e.message);
			}
		}

		private static void println(string message) { print("%s\n".printf(message)); }

   		public static int main (string[] args) {
    	    Gtk.init (ref args);
			string session_name = "default";
			bool incognito = false;
			for(int i = 0; i < args.length; i++) {
				println("Param %d: %s".printf(i ,args[i]));
				if (args[i].has_prefix("--session="))
					session_name = args[i].replace("--session=","");
				if (args[i] == "--private")
					incognito = true;
			}
			MyWhatsAppWebApp app = new MyWhatsAppWebApp(session_name, incognito);
	        Gtk.main ();
	        return 0;
		}
	}
}
