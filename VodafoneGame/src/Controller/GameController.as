package Controller
{
	import Model.*;
	
	import r1.deval.D;
		
	public class GameController
	{	
		public function GameController(levelModel : LevelModel)
		{
			mLevelModel = levelModel;
			mCharacter = new Character();
			
			mCurrNode = mLevelModel.FindNodeByName("Inicio");
			
			if (mCurrNode == null && (mLevelModel.Nodes.length > 0))
			{
				mCurrNode = mLevelModel.Nodes[0];
			}
			
			if (mCurrNode != null)
			{
				mCharacter.NodoPrevio = mCurrNode.Name;
				mCharacter.NodoActual = mCurrNode.Name;
			}
		}
		
		public function OnEnter() : Object
		{
			var ret : Object = { Code:"OK", Message:"" };
			
			trace("Ejecutando código de entrada al nodo " + mCurrNode.OnEnterCode);
			
			mCharacter.ResetRequestedState();
			
			try {				
				D.eval(mCurrNode.OnEnterCode, mCharacter, mCharacter);
				
				ret = ProcessRequestedState(); 
			}
			catch (e : Error)
			{
				ret.Code = "ERROR"; 
				ret.Message = "Error de parseo en el codigo! :\n" + mCurrNode.OnEnterCode; 
			}			
			
			return ret;
		}
		
		private function ProcessRequestedState() : Object
		{
			var ret : Object = { Code:"OK", Message:"" };
			
			if (mCharacter.RequestedState != "")
			{
				var changeToNode : Object = mLevelModel.FindNodeByName(mCharacter.RequestedState);
				
				if (changeToNode != null)
				{
					ChangeToNode(changeToNode);
					
					ret.Code = "NODECHANGE";
					ret.Message = "Se cambio de estado en el OnEnter del nodo, destino : " + mCharacter.RequestedState;
				}
				else
				{
					ret.Code = "ERROR";
					ret.Message = "Intento de Goto a nodo desconocido, destino : " + mCharacter.RequestedState;
				}
			}
			
			return ret;
		}
		
		private function ChangeToNode(changeToNode : Object):void
		{
			mCharacter.NodoPrevio = mCharacter.NodoActual;
			mCurrNode = changeToNode;
			mCharacter.NodoActual = mCurrNode.Name;
		}
		
		public function ExecuteProduct(name : String) : Object
		{
			var ret : Object = { Code:"OK", Message:"" };
			
			mCharacter.ResetRequestedState();
			
			var productNode : Object = mLevelModel.FindNodeByName(name);
			if (productNode == null)
			{
				ret.Code = "ERROR";
				ret.Message = "No se encontró el nodo del producto : " + name;
			}
			else
			{
				ret.Message = "Cambiado a nodo del producto, Nombre: " + name;
				
				ChangeToNode(productNode);								
			}
			
			return ret;
		}
		
		public function GetQuestion() : String
		{
			if (mCombineWith == "")
				return mLevelModel.FindTextByID(mCurrNode.Question);
			else
				return mLevelModel.FindTextByID(mCombineWith);
		}
		
		public function GetEnterMovieClip() : Object
		{
			if (mCombineWithMovieClip != null)
				return mCombineWithMovieClip;
			else
				return mCurrNode.EnterMovieClip;
		}
		
		public function GetIdleMovieClip() : Object
		{
			if (mCombineWithIdleMovieClip != null)
				return mCombineWithIdleMovieClip;
			else
				return mCurrNode.IdleMovieClip;
		}
		
		public function ChooseAnswer(idxAnswer : int) : Object
		{
			var ret : Object = { Code:"OK", Message:"" };
			
			var text : String = mCurrNode.Answers[idxAnswer].Text;
			trace("Ejecutando Respuesta: " + text);
			
			var code : String = mCurrNode.Answers[idxAnswer].ExecuteCode;
			trace("Ejecutando codigo : " + code);
			
			mCharacter.ResetRequestedState();
			mCombineWith = "";
			mCombineWithMovieClip = null;
			mCombineWithIdleMovieClip = null;
			
			try {				
				D.eval(code, mCharacter, mCharacter);
				
				// Sumamos vida propia de la respuesta
				var sumaVida : Number = mCurrNode.Answers[idxAnswer].ScoreLife;
				mCharacter.Vida += sumaVida * TheCharacter.MultiplicadorVida;
				mCharacter.Puntuacion += sumaVida * TheCharacter.MultiplicadorVida;
				
				// Saltamos de nodo
				var changeToNode : Object = null;
				var changeToName : String = "";
				
				if (mCharacter.RequestedState != "")
				{
					changeToName = mCharacter.RequestedState;
					changeToNode = mLevelModel.FindNodeByName(mCharacter.RequestedState);	
				}
				else
				if (mCurrNode.Answers[idxAnswer].DefaultGotoNode != "")
				{
					changeToName = mCurrNode.Answers[idxAnswer].DefaultGotoNode;
					changeToNode = mLevelModel.FindNodeByName(changeToName);
					
					// Sobreescribimos el nodo que entra
					mCombineWith = mCurrNode.Answers[idxAnswer].CombineWith;
					mCombineWithMovieClip = mCurrNode.Answers[idxAnswer].ExitMovieClip;
					mCombineWithIdleMovieClip = mCurrNode.Answers[idxAnswer].IdleMovieClip;
				}
				
				if (changeToNode != null)
				{ 
					ChangeToNode(changeToNode);
										
					ret.Code = "NODECHANGE";
					ret.Message = "Cambio de nodo en el script, destino : " + changeToName;			
				} 
				else if (changeToName != "")
				{
					ret.Code = "ERROR";
					ret.Message = "No se encontró el nodo destino de nombre: " + changeToName;
				}
				else
				{
					ret.Code = "ERROR";
					ret.Message = "Nodo destino indefinido";
				}
			}
			catch (e : Error)
			{
				ret.Code = "ERROR";
				ret.Message = "Error de sintaxis en el codigo! :\n" + code; 
			}
		
			return ret;
		}
				
		public function ShallIShowIt(idxAnswer : int) : Boolean
		{
			var ret : Boolean = false;
			
			try {
				ret = D.evalToBoolean(mCurrNode.Answers[idxAnswer].ConditionCode, mCharacter, mCharacter);
			}
			catch (e : Error)
			{
				ret = true;
			}
			
			return ret;
		}
		
		public static function IsValidCode(code : String) : Boolean
		{
			var bRet : Boolean = true;
			
			try {
				D.parseProgram(code);
			}
			catch (e : Error) {
				bRet = false;
			}
			
			return bRet;
		}
		
		
		public function GetLevelModel() : LevelModel 
		{ 
			return mLevelModel; 
		}
		
		public function get TheCharacter() : Character { return mCharacter; }
		public function get CurrentNode() : Object { return mCurrNode; }
				
		private var mLevelModel : LevelModel;
		private var mCharacter : Character;
		private var mCurrNode : Object;
				
		private var mCombineWith : String = "";
		private var mCombineWithMovieClip : Object = null;
		private var mCombineWithIdleMovieClip : Object = null;
	}
}