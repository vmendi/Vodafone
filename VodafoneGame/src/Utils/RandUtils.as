package Utils
{
	public class RandUtils
	{
		static public function Shuffle(a:Array) : Array 
		{
			var mixed : Array = a.slice(0, a.length);
			for (var i:uint = 0; i < a.length; i++)
			{
				var randomNum:Number = Math.round(Math.random() * (a.length-1));
				var tmp:Object = mixed[i];				 
				mixed[i] = mixed[randomNum];
				mixed[randomNum] = tmp;
			}
			 
			return mixed;
		}
		
		static public function GenerateShuffledArray(maxIdx : int) : Array
		{
			var ret : Array = new Array();
			for (var c : int = 0; c < maxIdx; c++)
				ret.push(c);
			return Shuffle(ret);
		}

	}
}