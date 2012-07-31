package Model
{	
	import flash.events.*;
	import flash.net.*;
	
	import mx.collections.ArrayCollection;
	import mx.controls.SWFLoader;
	
	//
	// - CurrentLevelChanged: Cuando ha cambiado la URL del nivel (puede haberse cargado un nuevo proyecto o no)
	// - RefreshComplete: Cuando se ha cargado hasta el útlimo movieclip en un refresco. Tb se manda cuando se carga un nivel
	// - LevelLoaded: Cuando se ha cargado hasta el último movieclip del nivel por motivo de una petición de carga de nivel 
	// - LevelError: Cualquier error durante la carga o el refresco
	//
	[Bindable]
	public dynamic class LevelModel
	{
		public var Nodes : ArrayCollection;
		public var Texts : ArrayCollection;
		public var SelectedNode : Object;
		
		
		// Path+fileName (miCarpeta/Level.xml) relativo al directorio workspace desde el que se cargó el nivel
		public function get CurrentLevel() : String { return mCurrentLevel; }
		public function set CurrentLevel(url : String) : void
		{
			mCurrentLevel = url;
			dispatchEvent(new Event("CurrentLevelChanged"));
		}
		// Path relativo al workspace desde el que se cargaran los recursos pertinentes al level
		public function get AssetPath() : String { return mAssetPath; }
		public function set AssetPath(path : String) : void 
		{ 
			mAssetPath = path;
			dispatchEvent(new Event("AssetPathChanged")); 
		}
		
		public function get Background() : Object { return mBackground; }
		public function get Intro() : Object { return mIntro; }
		public function get Final() : Object { return mFinal; }

		public function LevelModel()
		{
			Nodes = new ArrayCollection();
			Texts = new ArrayCollection();
			
			mCurrentLevel = "Nuevo";
			mAssetPath = "Assets";
			mBackground = { MovieClipName:"GUI/Fondo01.swf" };
			mIntro = { MovieClipName:"Intro.swf" };
			mFinal = { MovieClipName:"Final.swf" };
		}
		
		public function AddText(id : String) : Object
		{
			var newText : Object = new Object;
			newText.ID = id;
			newText.Text = "Default text";
			
			Texts.addItem(newText);
			
			return newText;
		}
		
		public function RemoveText(text : Object) : void
		{
			var idx : int = Texts.getItemIndex(text);
			Texts.removeItemAt(idx);
		}
			
		public function AddNode(name : String) : Object
		{
			var newNode : Object = new Object;
			
			newNode.Name = name;
			newNode.Question = "Default Question";
			newNode.Answers = new ArrayCollection();
			newNode.EnterMovieClipName = "DefaultEnter.swf";
			newNode.IdleMovieClipName = "DefaultIdle.swf";
			newNode.OnEnterCode = "";
			
			Nodes.addItem(newNode);
			
			return newNode;
		}

		public function RemoveNode(node : Object) : void
		{
			var idx : int = Nodes.getItemIndex(node);
        	Nodes.removeItemAt(idx);
		}
		
		public function AddAnswer(onNode : Object) : Object
		{
			var answer : Object = new Object();
			answer.Text = "Default Answer 0";
			answer.ExecuteCode = "";
			answer.ConditionCode = "return true;";
			answer.ExitMovieClipName = "";
			answer.IdleMovieClipName = "";
			answer.DefaultGotoNode = "";
			answer.ScoreLife = 0;
			answer.CombineWith = "";
			
			onNode.Answers.addItem(answer);
			
			return answer;
		}
			
		public function RemoveAnswer(onNode : Object, which : Object) : void
		{
			var idx : int = onNode.Answers.getItemIndex(which);
        	onNode.Answers.removeItemAt(idx);
		}
	
			
		public function RefreshMovieClips() : void
		{
			var temp : MovieClipLoader = new MovieClipLoader(this);
			temp.addEventListener("LoadComplete", OnRefreshComplete);
			temp.Load();
		}
		
		private function OnRefreshComplete(event:Event):void
		{
			event.target.removeEventListener("LoadComplete", OnRefreshComplete);
			dispatchEvent(new Event("RefreshComplete"));
			
			if (mbSendLevelLoaded)
			{
				dispatchEvent(new Event("LevelLoaded"));
				mbSendLevelLoaded = false;
			}
		}
		
		public function FindNodeByName(name : String) : Object
		{
			var ret : Object = null;
			for each(var node : Object in Nodes)
			{
				if (node.Name == name)
				{
					ret = node;
					break;
				}
			}			
			return ret;
		}
	
		public function FindTextByID(id : String) : String
		{
			var ret:String = id;
			
			for each (var txt : Object in Texts)
			{
				if (txt.ID == id)
				{
					ret = txt.Text;
					break;
				}
			}
			return ret;
		}
		
		public function LoadLevel(url : String) : void
		{			
			var myXMLURL:URLRequest = new URLRequest(url);
			var myLoader:URLLoader = new URLLoader();
			myLoader.addEventListener("complete", xmlLoaded);
			myLoader.addEventListener("ioError", xmlIOError);
			myLoader.addEventListener("securityError", securityError);
			myLoader.load(myXMLURL);
						
			function xmlLoaded(event:Event):void
			{
				var myXML:XML = XML(myLoader.data);
				Nodes = new ArrayCollection();
								
				for each(var nodeXML : XML in myXML.child("Node"))
				{
					var node : Object = new Object();
					node.Name = nodeXML.Name.toString();
					node.Question = nodeXML.Question.toString();
					node.Answers = new ArrayCollection();
					for each (var answerXML : XML in nodeXML.Answers.child("Answer"))
					{
						var answer : Object = new Object();
						answer.Text = answerXML.Text.toString();
						answer.ExecuteCode = answerXML.ExecuteCode.toString();
						answer.ConditionCode = answerXML.ConditionCode.toString();
						answer.ExitMovieClipName = answerXML.ExitMovieClipName.toString();
						answer.IdleMovieClipName = answerXML.IdleMovieClipName.toString();
						answer.DefaultGotoNode = answerXML.DefaultGotoNode.toString();
						answer.ScoreLife = answerXML.ScoreLife.toString();
						answer.CombineWith = answerXML.CombineWith.toString();
						node.Answers.addItem(answer);
					}
					
					node.EnterMovieClipName = nodeXML.EnterMovieClipName.toString();
					node.IdleMovieClipName = nodeXML.IdleMovieClipName.toString();
					node.OnEnterCode = nodeXML.OnEnterCode.toString();
					
					Nodes.addItem(node);
				}
				
				Texts = new ArrayCollection();
				
				for each(var textXML : XML in myXML.child("DaText"))
				{
					var text : Object = new Object();
					text.ID = textXML.ID.toString();
					text.Text = textXML.Text.toString();
					
					Texts.addItem(text);
				}
				
				// Cambiamos el path del proyecto
			    CurrentLevel = url;
			    
			    var xmlPath : XMLList = myXML.child("AssetPath");				
				if (xmlPath.length() != 0)
					AssetPath = xmlPath.toString();
				
			    mbSendLevelLoaded = true;
			    RefreshMovieClips();
			}
			
			function xmlIOError(event:IOErrorEvent):void
			{
				dispatchEvent(new IOErrorEvent("LevelError", false, false, "Error Cargando " + myXMLURL.url));
			}
			
			function securityError(event:SecurityErrorEvent):void
			{
				dispatchEvent(new IOErrorEvent("LevelError", false, false, "Error de seguridad cargando " + myXMLURL.url));
			}
		}
		
		public function GetSaveXML() : XML
		{
			var saveXML:XML = <Level></Level>

			for (var c : int = 0; c < Nodes.length; c++)
			{
				var nodeXML : XML = 
								<Node>
									<Name>{Nodes[c].Name}</Name>
									<Question>{Nodes[c].Question}</Question>
									<Answers></Answers>
									<RangedVars></RangedVars>
									<EnterMovieClipName>{Nodes[c].EnterMovieClipName}</EnterMovieClipName>
									<IdleMovieClipName>{Nodes[c].IdleMovieClipName}</IdleMovieClipName>
									<OnEnterCode>{Nodes[c].OnEnterCode}</OnEnterCode>
								</Node>
				for (var d : int = 0; d < Nodes[c].Answers.length; d++)
				{
					var answerXML : XML =
								<Answer>
									<Text>{Nodes[c].Answers[d].Text}</Text>
									<ExecuteCode>{Nodes[c].Answers[d].ExecuteCode}</ExecuteCode>
									<ConditionCode>{Nodes[c].Answers[d].ConditionCode}</ConditionCode>
									<ExitMovieClipName>{Nodes[c].Answers[d].ExitMovieClipName}</ExitMovieClipName>
									<IdleMovieClipName>{Nodes[c].Answers[d].IdleMovieClipName}</IdleMovieClipName>
									<DefaultGotoNode>{Nodes[c].Answers[d].DefaultGotoNode}</DefaultGotoNode>
									<ScoreLife>{Nodes[c].Answers[d].ScoreLife}</ScoreLife>
									<CombineWith>{Nodes[c].Answers[d].CombineWith}</CombineWith>
								</Answer>
					
					nodeXML.Answers.appendChild(answerXML);
				}
								
				saveXML.appendChild(nodeXML);
			}
			
			for (c = 0; c < Texts.length; c++)
			{
				var textXML : XML =	<DaText>
										<ID>{Texts[c].ID}</ID>
										<Text>{Texts[c].Text}</Text>
									</DaText>
									
				saveXML.appendChild(textXML);					
			}
			
			var assetPathXML : XML = <AssetPath>{AssetPath}</AssetPath>
			saveXML.appendChild(assetPathXML);

			return saveXML;
		}
		
		private var mBackground : Object;
		private var mIntro : Object;
		private var mFinal : Object;
		private var mCurrentLevel : String;
		private var mAssetPath : String;
		
		private var mbSendLevelLoaded : Boolean = false;
	}
}

import flash.events.Event;
import flash.events.IOErrorEvent;
import mx.controls.SWFLoader;
import Model.LevelModel;
import flash.events.EventDispatcher;

internal class MovieClipLoader extends EventDispatcher
{
	public function MovieClipLoader(levelModel : LevelModel) : void
	{
		mLevelModel = levelModel;
	}	
	
	public function Load() : void
	{
		mUniques = Gather();
		
		mTargetMovieClips = mUniques.length + 3;
		
		for each (var unique : Object in mUniques)
		{
			var loader : MovieClipLoadHelper = new MovieClipLoadHelper(OnMovieClipLoaded, unique.URL, unique, "DaMovieClip");
			mLoaders.push(loader);	
		}
				
		loader = new MovieClipLoadHelper(OnMovieClipLoaded, mLevelModel.Background.MovieClipName, 
					  	 				mLevelModel.Background, "DaMovieClip");
		mLoaders.push(loader);
		
		loader = new MovieClipLoadHelper(OnMovieClipLoaded, mLevelModel.AssetPath+"/"+mLevelModel.Intro.MovieClipName, 
										mLevelModel.Intro, "DaMovieClip");
		mLoaders.push(loader);
		
		loader = new MovieClipLoadHelper(OnMovieClipLoaded, mLevelModel.AssetPath+"/"+mLevelModel.Final.MovieClipName, 
										mLevelModel.Final, "DaMovieClip");
		mLoaders.push(loader);
	}
	
	private function Gather() : Array
	{
		var urls : Array = new Array();
		
		for each (var node : Object in mLevelModel.Nodes)
		{
			if (node.EnterMovieClipName != "")
			{
				var url : String = mLevelModel.AssetPath+"/"+node.EnterMovieClipName;				
				if (urls.indexOf(url) == -1)
					urls.push(url);
			}
			if (node.IdleMovieClipName != "")
			{
				url = mLevelModel.AssetPath+"/"+node.IdleMovieClipName;	
				if (urls.indexOf(url) == -1)
					urls.push(url);
			}				
			
			for each (var answer : Object in node.Answers)
			{
				if (answer.ExitMovieClipName != "")
				{
					url = mLevelModel.AssetPath+"/"+answer.ExitMovieClipName;
					if (urls.indexOf(url) == -1)
						urls.push(url);
				}
				if (answer.IdleMovieClipName != "")
				{
					url = mLevelModel.AssetPath+"/"+answer.IdleMovieClipName;
					if (urls.indexOf(url) == -1)
						urls.push(url);
				}
			}
		}
		
		var ret : Array = new Array;
		for each (var str : String in urls)
			ret.push({URL:str, DaMovieClip:null});
		
		return ret;
	}

	private function OnMovieClipLoaded(mc : Object) : void
	{
		mTargetMovieClips--;
				
		if (mTargetMovieClips == 0)
		{
			Assign();

			dispatchEvent(new Event("LoadComplete"));			
		}
	}
	
	private function Assign() : void
	{
		var tempHash : Object = new Object;
		
		for each (var unique : Object in mUniques)
			tempHash[unique.URL] = unique.DaMovieClip;
	
		for each (var node : Object in mLevelModel.Nodes)
		{
			node.EnterMovieClip = tempHash[mLevelModel.AssetPath+"/"+node.EnterMovieClipName];
			node.IdleMovieClip = tempHash[mLevelModel.AssetPath+"/"+node.IdleMovieClipName];
			
			for each (var answer : Object in node.Answers)
			{
				answer.ExitMovieClip = tempHash[mLevelModel.AssetPath+"/"+answer.ExitMovieClipName];
				answer.IdleMovieClip = tempHash[mLevelModel.AssetPath+"/"+answer.IdleMovieClipName];
			}
		}
	}
	
	private var mUniques : Array;
	private var mTargetMovieClips : int = 0;
	private var mLevelModel : LevelModel;
	private var mLoaders : Array = new Array();
}

internal class MovieClipLoadHelper
{
	public function MovieClipLoadHelper(notifyMe : Function, url : String, obj : Object, assignName : String)
	{
		mNotifyMe = notifyMe;
				
		mSWFLoader = new SWFLoader();
		mSWFLoader.addEventListener("complete", loaded);
		mSWFLoader.addEventListener("ioError", IOError);
		mSWFLoader.scaleContent = false;
		mSWFLoader.load(url);
		
		if (url == null)
		{		
			if (mNotifyMe != null)
				mNotifyMe(null);
		}
		
		function loaded(event:Event):void
		{
			obj[assignName] = event.target;
									
			if (mNotifyMe != null)
				mNotifyMe({URL:url, DaSWFLoader:event.target});
		}
		
		function IOError(event:IOErrorEvent):void
		{
			if (mNotifyMe != null)
				mNotifyMe(null);
							
			trace("Error cargando " + url);
		}
	}
 
 	private var mSWFLoader : SWFLoader;
 	private var mNotifyMe : Function = null;
}