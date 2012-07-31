package Controller
{
	import flash.events.Event;

	public class ShowProductsEvent extends Event
	{
		public var ProductNames : Array;
		
		public function ShowProductsEvent(type:String, arr:Array, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			ProductNames = arr;
			super(type, bubbles, cancelable);
		}
		
	}
}