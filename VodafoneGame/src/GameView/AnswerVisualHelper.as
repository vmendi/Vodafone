package GameView
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	import mx.effects.Fade;
	import mx.events.EffectEvent;
	import mx.events.NumericStepperEvent;
	
	public class AnswerVisualHelper extends EventDispatcher
	{
		public function AnswerVisualHelper(fromArray:Array)
		{
			mArray = fromArray;	
		}
		
		public function DoFinalBlink(mc:MovieClip) : void
		{
			mMCToBlink = mc;
			mNonShuffledIdx = mMCToBlink["AnswerIndex"];

			var timer : Timer = new Timer(50, 6);
			timer.addEventListener(TimerEvent.TIMER, OnTimerBlinkAnswer, false, 0, true);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, OnTimerComplete);
			timer.start();
		}
		
		public function DoEnterFadeIn() : void
		{
			var delay : Number = 0;
			for (var c:int = 0; c < mArray.length; c++)
			{
				var comp : UIComponent = mArray[c] as UIComponent;
				var fade : Fade = new Fade(comp);
				comp.alpha = 0.0;
				fade.alphaFrom = 0.0;
				fade.alphaTo = 1.0;
				fade.duration = 200;
				fade.startDelay = delay;
				fade.play();
				
				delay+=100;
				
				if (c == mArray.length - 1)
					fade.addEventListener(EffectEvent.EFFECT_END, OnLastOneEnd);
			}
			
			if (mArray.length == 0)
				dispatchEvent(new Event("EnterFadeInComplete"));
		} 
		
		private function OnLastOneEnd(event:EffectEvent):void
		{
			event.target.removeEventListener(EffectEvent.EFFECT_END, OnLastOneEnd);
			dispatchEvent(new Event("EnterFadeInComplete"));
		}
		
		private function OnTimerBlinkAnswer(event:TimerEvent):void
		{
			mMCToBlink.visible = !mMCToBlink.visible;	
		}
		
		private function OnTimerComplete(event:TimerEvent) : void
		{
			event.target.removeEventListener(TimerEvent.TIMER_COMPLETE, OnTimerComplete);
			dispatchEvent(new NumericStepperEvent("BlinkingComplete", false, false, mNonShuffledIdx));
		}
		
		private var mMCToBlink : MovieClip = null;
		private var mArray : Array;
		private var mNonShuffledIdx : int;
	}
}