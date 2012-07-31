package Utils
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	
	public class MovieClipMouseDisabler
	{
		static public function DisableMouse(parent : DisplayObjectContainer) : void
		{
			parent.mouseEnabled = false;
			for (var c : int = 0; c < parent.numChildren; c++)
			{
				var container : DisplayObjectContainer = parent.getChildAt(c) as DisplayObjectContainer;
				if (container != null)
					DisableMouse(container);
				else
				{
					var interactive : InteractiveObject = parent.getChildAt(c) as InteractiveObject;
					if (interactive != null)
						interactive.mouseEnabled = false;
				}
			}					
		}
	}
}