package
{
	import Utils.Server;
	import Utils.ServerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;

	public class KeepAlive extends EventDispatcher
	{
		public function KeepAlive(dni : String, target:IEventDispatcher=null)
		{
			super(target);
			
			mDNI = dni;		
		}
		
		public function Start():void
		{
			mTimer = new Timer(30000);
			mTimer.addEventListener(TimerEvent.TIMER, OnTimer, false, 0, true);
			mTimer.start();
			
			mServer = new Server();
			mServer.addEventListener("RequestComplete", OnRequestComplete, false, 0, true);
		}
		
		public function Stop():void
		{
			mTimer.removeEventListener(TimerEvent.TIMER, OnTimer);
			
			var variables : URLVariables = new URLVariables;
			variables.cdni = mDNI; 
			variables.action = 1;
			
			mServer.Request(variables, "keepAlive.php");
		}
		
		private function OnTimer(event:TimerEvent):void
		{
			var variables : URLVariables = new URLVariables;
			variables.cdni = mDNI; 
			variables.action = 0;
			
			mServer.Request(variables, "keepAlive.php");
		}
		
		private function OnRequestComplete(event:ServerEvent):void
		{
			trace("KeepAlive: " + event.Data);
		}
		
		private var mDNI : String;
		private var mServer : Server;
		private var mTimer : Timer;
	}
}