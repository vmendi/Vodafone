package Utils
{
	import flash.events.Event;

	public class ServerEvent extends Event
	{
		public var Data : Object;
		
		public function ServerEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			Data = data;
			super(type, bubbles, cancelable);
		}
		
	}
}