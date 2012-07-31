package EditorUtils
{
	import Model.LevelModel;
	import flash.filesystem.*;
	
	public class SaveLevelModel
	{
		public static function SaveToDisk(url : String, levelModel : LevelModel) : void
		{
			var saveXML : XML = levelModel.GetSaveXML();
			
			var file : File = new File(url);
			var fileStream : FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(saveXML);
			fileStream.close();
		}
	}
}