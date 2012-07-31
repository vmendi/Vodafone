package Utils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	public class Server extends EventDispatcher
	{
		private var mBase : String = "http://formacionvodafone.magiainteractiva.com/";
		
		public function Server()
		{		
		}
		
		public function Request(variables:URLVariables, func : String) : void
		{	
			var antiCache : int = Math.random()*9999999;
			var url:String = mBase+func+"?"+antiCache;
			var req:URLRequest = new URLRequest(url);
			req.method = URLRequestMethod.POST;
			req.data = variables;
			
			mURLLoader = new URLLoader();
			
			mURLLoader.addEventListener(Event.COMPLETE, onRequestComplete);
			mURLLoader.addEventListener(IOErrorEvent.IO_ERROR, onRequestError);
			
			try	{
				mURLLoader.load(req);
			} 
			catch (error:Error)
			{
				dispatchEvent(new Event("RequestError"));
			}
		}		
		
		private function onRequestComplete(e:Event) : void
		{
			var loader:URLLoader = e.target as URLLoader;
		
			dispatchEvent(new ServerEvent("RequestComplete", loader.data));	
		}
		
		private function onRequestError(e:IOErrorEvent):void
		{
			trace("Server: Request Error");
			dispatchEvent(new Event("RequestError"));
		}
		
		private var mURLLoader : URLLoader;
	}
}