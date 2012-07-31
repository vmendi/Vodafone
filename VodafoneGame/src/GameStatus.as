package
{
	import Controller.GameController;
	
	import Utils.RandUtils;
	import Utils.Server;
	import Utils.ServerEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	import flash.net.URLVariables;
	
	public class GameStatus extends EventDispatcher
	{
		public var PuntosTienda : Number = 0;
		
		
		public function GameStatus()
		{
		}

		public function LoadStatus(dni : String) : void
		{	
			mDNI = dni;
			mRemainingLevels = [0, 1, 2, 3, 4];
			mRemainingLevels = Utils.RandUtils.Shuffle(mRemainingLevels);
			
			RequestStatusFromServer();
		}
		
		private function RequestStatusFromServer() : void
		{
			var variables:URLVariables = new URLVariables();
			variables.cdni = mDNI;
			
			var serv : Server = new Server();
			serv.addEventListener("RequestComplete", OnRequestStatusComplete);
			serv.addEventListener("RequestError", OnRequestStatusError);
			serv.Request(variables, "getJugadorStatus.php");
		}

		private function OnRequestStatusComplete(event:ServerEvent):void
		{
			var responseXML : XML = new XML(event.Data);
			var errorString : String = "";
			
			if (responseXML.name().localName == "error")
			{
				var item : XML = responseXML.children()[0];
				
				// Es la primera vez que jugamos, hay que pedir nick y sexo, se encarga alguien por fuera
				if (item != "NOT_FOUND")
					dispatchEvent(new TextEvent("StatusError", false, false, "Error en la comunicación con el servidor"));
				else
					dispatchEvent(new Event("LoadStatusComplete"));
			}
			else
			{
				mNick = responseXML.cnick;
				mChico = parseInt(responseXML.bsexo) == 1;
				
				trace(responseXML.cstatus.toString());
				mRemainingLevels = new Array();
				for each (item in responseXML.cstatus.status.elements("level"))
				{
					var idxLevel : int = parseInt(item.toString());
					mRemainingLevels.push(idxLevel);
				}
				mRemainingLevels = Utils.RandUtils.Shuffle(mRemainingLevels);
				
				mIsCompleted = responseXML.cstatus.status.IsCompleted;
				mScoreSoFar = responseXML.cstatus.status.ScoreSoFar;
				mSatisfaccionSoFar = responseXML.cstatus.status.SatisfaccionSoFar;
				
				mTiendaStatusXML = XML(responseXML.cstatus.status.TiendaStatus);
																				
				dispatchEvent(new Event("LoadStatusComplete"));
			}
		}
		
		private function OnRequestStatusError(event:Event):void
		{
			dispatchEvent(new TextEvent("StatusError", false, false, "Error en la comunicación con el servidor"));
		}
		
		public function AddStatus() : void
		{
			var variables : URLVariables = new URLVariables();
			variables.cdni = mDNI;
			variables.cnick = mNick;
			variables.bsexo = mChico? 1 : 0;
			variables.cstatus = <status>
								<level>0</level><level>1</level><level>2</level><level>3</level><level>4</level>
								<IsCompleted>false</IsCompleted>
								<ScoreSoFar>0</ScoreSoFar>
								<SatisfaccionSoFar>0</SatisfaccionSoFar>
								</status>
			variables.cstatus.appendChild(mTiendaStatusXML);
				
			var serv : Server = new Server();
			serv.addEventListener("RequestComplete", OnAddStatusComplete);
			serv.addEventListener("RequestError", OnRequestStatusError);
			serv.Request(variables, "addJugador.php");
		}
		
		private function OnAddStatusComplete(event:ServerEvent):void
		{
			var responseXML : XML = new XML(event.Data);
						
			if (responseXML.name().localName == "error")		
				dispatchEvent(new TextEvent("StatusError", false, false, "Error en la comunicación con el servidor"));
			else
				dispatchEvent(new Event("AddStatusComplete"));
		}

		
		public function GetCurrentLevelName() : String
		{
			return LEVELS[mRemainingLevels[mCurrentLevel]];
		}
		
		public function NextLevel(gameController : GameController) : void
		{
			mScoreSoFar += gameController.TheCharacter.Puntuacion;
			
			if ((!mIsCompleted) && (mRemainingLevels.length == 5))
				mSatisfaccionSoFar = gameController.TheCharacter.Vida;
			else
				mSatisfaccionSoFar = (mSatisfaccionSoFar + gameController.TheCharacter.Vida)*0.5;
			
			SavePuntuacion(gameController);			
		}
		
		
		private function SavePuntuacion(gameController : GameController):void
		{
			var variables : URLVariables = new URLVariables();
			variables.cdni = mDNI;
			variables.nidnivel = mRemainingLevels[mCurrentLevel];
			variables.bexito = gameController.TheCharacter.Success? 1 : 0;
			variables.ntiempo = gameController.TheCharacter.GetTotalPlayedTime();
			variables.nvida = int(gameController.TheCharacter.Vida);
			variables.npuntuacion = int(gameController.TheCharacter.Puntuacion);
			variables.bpavendido = gameController.TheCharacter.GetPAVendido()? 1 : 0;
			variables.bpbvendido = gameController.TheCharacter.GetPBVendido()? 1 : 0;
			variables.clog = <log></log>
			variables.cnodosalida = gameController.CurrentNode.Name;
			
			var serv : Server = new Server();
			serv.addEventListener("RequestComplete", OnSavePuntuacionComplete);
			serv.addEventListener("RequestError", OnRequestStatusError);
			serv.Request(variables, "addPuntuacion.php");
		}
		
		private function OnSavePuntuacionComplete(event:ServerEvent):void
		{
			trace("OnSavePuntuacionComplete");
			
			var responseXML : XML = new XML(event.Data);
						
			if (responseXML.name().localName == "error")		
				dispatchEvent(new TextEvent("StatusError", false, false, "Error en la comunicación con el servidor"));
			else
				ProcessStatus();
		}
		
		private function ProcessStatus() : void
		{
			mRemainingLevels.splice(mCurrentLevel, 1);
				
			if (mRemainingLevels.length == 0)
			{
				if (!mIsCompleted)
				{
					mIsCompleted = true;
					mHasBeenCompleted = true;
				}
				
				mRemainingLevels = [0, 1, 2, 3, 4];
				mRemainingLevels = Utils.RandUtils.Shuffle(mRemainingLevels);
			}
			else
			if (mCurrentLevel >= mRemainingLevels.length)
			{
				mCurrentLevel = 0;
			}
			
			SaveStatus();
		}
		
		private function SaveStatus() : void
		{
			var myXML : XML = <status></status>
			
			for (var c : int = 0; c < mRemainingLevels.length; c++)
			{
				var levelXML : XML = <level>{mRemainingLevels[c]}</level>
				myXML.appendChild(levelXML);	
			}
			
			var isCompleted : XML = <IsCompleted>{mIsCompleted}</IsCompleted>
			myXML.appendChild(isCompleted);
				
			var score : XML = <ScoreSoFar>{mScoreSoFar}</ScoreSoFar>
			myXML.appendChild(score);

			var satisfaccion : XML = <SatisfaccionSoFar>{mSatisfaccionSoFar}</SatisfaccionSoFar>
			myXML.appendChild(satisfaccion);
			
			myXML.appendChild(mTiendaStatusXML);
						
			var variables : URLVariables = new URLVariables();
			variables.cdni = mDNI;
			variables.cstatus = myXML.toString();
			
			trace("esto es lo que grabamos");
			trace(myXML.toString());
			
			var serv : Server = new Server();
			serv.addEventListener("RequestComplete", OnSaveStatusComplete);
			serv.addEventListener("RequestError", OnRequestStatusError);
			serv.Request(variables, "setJugadorStatus.php");
		}
		
		private function OnSaveStatusComplete(event:ServerEvent):void
		{
			trace("OnSaveStatusComplete");
			var responseXML : XML = new XML(event.Data);
						
			if (responseXML.name().localName == "error")		
				dispatchEvent(new TextEvent("StatusError", false, false, "Error en la comunicación con el servidor"));
			else
				dispatchEvent(new Event("NextLevelComplete"));
		}
		
		public function get DNI() : String { return mDNI;}		
		
		public function get Nick() : String { return mNick;}
		public function set Nick(v : String):void { mNick = v; }
		
		public function get Chico() : Boolean { return mChico;}
		public function set Chico(v : Boolean):void { mChico = v; }
		
		public function get FirstTime() : Boolean { return mFirstTime; }
		public function set FirstTime(v : Boolean):void { mFirstTime = v; }
		
		public function get IsCompleted() : Boolean { return mIsCompleted; }
		public function get HasBeenCompleted() : Boolean { return mHasBeenCompleted; }
		public function get ScoreSoFar() : Number { return mScoreSoFar; }
		public function get SatisfaccionSoFar() : Number { return mSatisfaccionSoFar; }
		
		public function ClearHasBeenCompleted() : void { mHasBeenCompleted = false; }
		
		public function set TiendaStatus(daXML : XML) : void { mTiendaStatusXML = daXML; }
		public function get TiendaStatus() : XML { return mTiendaStatusXML; }
		
		private var mDNI : String = "NotInit";
		private var mCurrentLevel : int = 0;		
		private var mNick : String = "";
		private var mChico : Boolean = true;
		private var mFirstTime : Boolean = true;
		
		private var mIsCompleted : Boolean = false;
		private var mHasBeenCompleted : Boolean = false;
		private var mScoreSoFar : Number = 0;
		private var mSatisfaccionSoFar : Number = 0;
		
		private var mRemainingLevels : Array;
		private var mTiendaStatusXML : XML;
		
		private var LEVELS : Array = [
										"Levels/Chica.xml", 
										"Levels/Extranjero.xml", 
								   		"Levels/Ejecutivo.xml", 
								   		"Levels/Senora.xml",
								   		"Levels/Tekki.xml" 
							   		];
	}
}