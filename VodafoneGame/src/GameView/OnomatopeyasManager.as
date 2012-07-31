package GameView
{
	import Utils.GenericEvent;
	import Utils.MovieClipListener;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import mx.core.UIComponent;
	
	
	public class OnomatopeyasManager extends EventDispatcher
	{
		public function OnomatopeyasManager(gameView : GameView)
		{
			mGameArea = gameView.GetGameArea();
			mGameView = gameView;
			
			gameView.GetGameController().TheCharacter.addEventListener("ShowOnomatopeya", OnShowOnomatopeyaEvent, false, 0, true);
			gameView.GetGameController().TheCharacter.addEventListener("HideBackOnomatopeya", OnHideBackOnomatopeyaEvent, false, 0, true);
		}

		private function OnShowOnomatopeyaEvent(event:GenericEvent):void
		{
			var mcOnomatopeya : MovieClip = new (getDefinitionByName(event.Data.Name) as Class);
						
			if (event.Data.IsFront)
			{
				var uiComp:UIComponent = new UIComponent();
				uiComp.addChild(mcOnomatopeya);
				uiComp.width = mcOnomatopeya.width;
				uiComp.height = mcOnomatopeya.height;
				uiComp.x = 0;
				uiComp.y = 0;
				mGameView.addChildAt(uiComp, mGameView.getChildIndex(mGameView.GetMarco()));
									
				var listener : MovieClipListener = new MovieClipListener();
				listener.listenToAnimEnd(mcOnomatopeya, OnFrontOnomatopeyaEnd, true, 1);		
			}
			else
			{
				if (mBackOnomatopeya != null)
					mGameArea.removeChild(mBackOnomatopeya);
				mBackOnomatopeya = new UIComponent();
				mBackOnomatopeya.addChild(mcOnomatopeya);
				mBackOnomatopeya.width = mcOnomatopeya.width;
				mBackOnomatopeya.height = mcOnomatopeya.height;
				mBackOnomatopeya.x = 0;
				mBackOnomatopeya.y = 0;
				mGameArea.addChildAt(mBackOnomatopeya, mGameArea.getChildIndex(mGameView.GetCurrCharacter()));
			}
		}
		
		private function OnFrontOnomatopeyaEnd(mc:MovieClip):void
		{
			mGameView.removeChild(mc.parent);
		}
		
		private function OnHideBackOnomatopeyaEvent(event:Event):void
		{
			if (mBackOnomatopeya != null)
			{
				mGameArea.removeChild(mBackOnomatopeya);
				mBackOnomatopeya = null;
			}
			else
			{
				trace("HideOnomatopeya sin estar mostrándose");
			}
		}
		
		private var mGameArea : UIComponent;
		private var mGameView : GameView;
		private var mBackOnomatopeya : UIComponent;
	}
}