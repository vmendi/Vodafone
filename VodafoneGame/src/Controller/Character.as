package Controller
{
	import Utils.GenericEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TextEvent;
	import flash.utils.getTimer;
	
	import mx.utils.ObjectUtil;

	
	public dynamic class Character extends EventDispatcher
	{
		public var DanoPorSegundo : Number = 1.0;
		public var MultiplicadorVida : Number = 1.0;
		public var PuntosTienda : int = 0;
		
		public function Character()
		{
			mStartTime = getTimer();
		}
		
		private var mStartTime : int = 0;
		public function GetTotalPlayedTime() : int
		{
			return int((getTimer() - mStartTime)/1000);
		}
		
		public function GetPAVendido() : Boolean
		{
			if (this.hasOwnProperty("PAvendido"))
				return this["PAvendido"] as Boolean;
			
			return false;
		}
		
		public function GetPBVendido() : Boolean
		{
			if (this.hasOwnProperty("PBvendido"))
				return this["PBvendido"] as Boolean;
			
			return false;
		}
		
		public function get RequestedState() : String { return mRequestedState; }
		public function ResetRequestedState() : void { mRequestedState = ""; }
		
		public function get Vida() : Number { return mVida; }
		public function set Vida(val : Number) : void
		{
			if (val < 0)
				val = 0;
			else if (val > 100)
				val = 100;

			mVida = val;
			
			if ((!mEnded) && mVida == 0)
			{
				mSuccess = false;
				mEndMessage = "¡Esa última respuesta te ha costado todo el tiempo restante!";
				mEndReason = "VidaAcabadaPorError";
				mEnded = true;
				
				dispatchEvent(new Event("VidaAcabadaPorError"));
			}
		}
				
		public function get Puntuacion() : Number { return mPuntuacion; }
		public function set Puntuacion(val:Number) : void
		{ 
			mPuntuacion = val;
			
			if (mPuntuacion < 0)
				mPuntuacion = 0; 
		} 
		
		public function get Success() : Boolean { return mSuccess; }
		public function get IsEnded() : Boolean { return mEnded; }
		public function get EndMessage() : String { return mEndMessage; }
		public function get EndReason() : String { return mEndReason; }
		
		public function GetParamsFormatedString() : String
		{
			var ret : String = "";
		
			var props : Array = ObjectUtil.getClassInfo(this).properties;
			
			for each(var prop : String in props)
			{
				if (prop != "RequestedState")
				{
					ret += prop + " = " + this[prop] + "\n";
				}
			}
			
			return ret;
		}
		
		public function GotoState(stateName : String) : void
		{
			mRequestedState = stateName;
		}
		
		public function DisableProduct(productName : String) : void
		{
			dispatchEvent(new TextEvent("ProductDisabled", false, false, productName));
		}
		
		public function RefreshVida() : void
		{
			var currTime : Number = getTimer();
			
			if (!mFirstTime)
			{
				var elapsed : Number = currTime - mLastTime;
				var dano : Number = DanoPorSegundo * elapsed / 1000.0;
				Vida -= dano;
				Puntuacion -= dano;
			}
			else
			{
				mFirstTime = false;
			}
						
			mLastTime = currTime;
			
			if (Vida == 0)
			{
				mSuccess = false;
				mEndMessage = "Se te ha agotado el tiempo";
				mEndReason = "VidaAcabadaPorTiempo";
				mEnded = true;
				
				dispatchEvent(new Event("VidaAcabadaPorTiempo"));
			}
		}
		
		public function OnPause():void
		{
			mLastTime = getTimer();
		}
		
		public function NivelFinalizado(exito : Boolean, mensaje : String):void
		{
			mSuccess = exito;
			mEndMessage = mensaje;
			mEndReason = "NivelFinalizado";
			mEnded = true;
			
			dispatchEvent(new Event("LevelComplete"));
		}
		
		public function ShowProducts(productNames : Array) : void
		{
			dispatchEvent(new ShowProductsEvent("ShowProductsEvent", productNames, false, false));
		}
		
		public function ShowFrontOnomatopeya(name : String) : void
		{
			dispatchEvent(new GenericEvent("ShowOnomatopeya", { Name:name, IsFront:true} , false, false));
		}
		
		public function ShowBackOnomatopeya(name : String) : void
		{
			dispatchEvent(new GenericEvent("ShowOnomatopeya", { Name:name, IsFront:false} , false, false));
		}
		
		public function HideBackOnomatopeya() : void
		{
			dispatchEvent(new GenericEvent("HideBackOnomatopeya", { } , false, false));
		}
		
		public function ShowFeedback(msg : String):void
		{
			dispatchEvent(new GenericEvent("ShowFeedback", msg, false, false));
		}
				
		
		private var mSuccess : Boolean = false;
		private var mEndMessage : String = "";
		private var mEnded : Boolean = false;
		private var mEndReason : String = "";  
		private var mVida : Number = 50.0;
		private var mPuntuacion : Number = 50.0;
		
		private var mFirstTime : Boolean = true;
		private var mLastTime : Number = 0;
		private var mRequestedState : String;
	}
}