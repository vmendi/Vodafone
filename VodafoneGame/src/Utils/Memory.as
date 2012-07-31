package Utils
{
	public class Memory
	{
		static public function killEm():void
        {
            try
            {
                new LocalConnection().connect('foo');
                new LocalConnection().connect('foo');
            }
            catch (e:*)
            {
            }
        }
	}
}