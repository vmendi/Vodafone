package Utils
{
	//
	// Para poder pasar parámetros a funciones puntero:
	//
	// mc.addFrameScript(mc.totalFrames-1,Delegate.create(myFunction,i));
	//
	public class Delegate
	{
		public static function create(handler:Function,...args):Function
		{
			return function(...innerArgs):void
			{
				handler.apply(this,innerArgs.concat(args));
			}
		}
	}

}