package EditorUtils
{
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.geom.Rectangle;
	
	import mx.core.Window;
	
	public class WindowUtils
	{
		public static function OnShow(name : String, nativeWindow : NativeWindow) : void
        {
        	if (!Config.GetInstance().HasKey(name+"X"))
        	{
        		// center the window on the screen
           		var screenBounds:Rectangle = Screen.mainScreen.bounds;
            	nativeWindow.x = (screenBounds.width - nativeWindow.width) / 2;
            	nativeWindow.y = (screenBounds.height - nativeWindow.height) / 2;
         	}
         	else
         	{
         		nativeWindow.x = parseFloat(Config.GetInstance().ReadValue(name+"X"));
         		nativeWindow.y = parseFloat(Config.GetInstance().ReadValue(name+"Y"));
         	}         
        }
        
        public static function OnMove(name : String, nativeWindow:NativeWindow) : void
        {
        	Config.GetInstance().WriteValue(name+"X", nativeWindow.x.toString());
       		Config.GetInstance().WriteValue(name+"Y", nativeWindow.y.toString());
        }

	}
}