package GameView
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class AudioManager
	{
		public function AudioManager()
		{
		}
		
		public function PlayMusic(muzak_path : String)  :void
		{
			try
			{
				mMusic = new Sound();
				var urlReq : URLRequest = new URLRequest(muzak_path);
				var buffer : SoundLoaderContext = new SoundLoaderContext( 3 * 1000 );
				mMusic.addEventListener(IOErrorEvent.IO_ERROR, OnLoadError, false, 0, true);
				mMusic.load(urlReq, buffer);
				mMusicSoundChannel = mMusic.play();
				mMusicSoundChannel.addEventListener(Event.SOUND_COMPLETE, OnMusicComplete, false, 0, true);
			}
			catch (e : *)
			{
				trace("Imposible reproducir música : " + muzak_path);
			}
		}
		
		private function OnLoadError(event:IOErrorEvent):void
		{
			trace("Imposible reproducir música : " + event.text);
		}
		
		private function OnMusicComplete(event:Event) : void
		{
			mMusicSoundChannel = mMusic.play();
			mMusicSoundChannel.addEventListener(Event.SOUND_COMPLETE, OnMusicComplete, false, 0, true);
			
			if (mIsMuted)
				MuteMusic();
		}
		
		public function StopMusic() : void
		{	
			if (mMusicSoundChannel != null)
				mMusicSoundChannel.stop();
			
			mMusic = null;
			mMusicSoundChannel = null;
		}
		
		public function MuteMusic() : void
		{
			var sndTransform : SoundTransform = new SoundTransform(0.0);
			mMusicSoundChannel.soundTransform = sndTransform;
			mIsMuted = true;
		}
		
		public function UnMuteMusic() : void
		{
			var sndTransform : SoundTransform = new SoundTransform(1.0);
			mMusicSoundChannel.soundTransform = sndTransform;
			mIsMuted = false;
		}
		
		public function FadeOutMusic():void
		{
			mTimer = new Timer(30);
			mTimer.addEventListener(TimerEvent.TIMER, OnFadeOutTimer);
			mTimer.start();
		}
		
		private function OnFadeOutTimer(event:TimerEvent):void
		{
			var sndTransform : SoundTransform = new SoundTransform(mMusicSoundChannel.soundTransform.volume*0.9);
			mMusicSoundChannel.soundTransform = sndTransform;
			if (sndTransform.volume < 0.05)
			{
				StopMusic();
				mTimer.removeEventListener(TimerEvent.TIMER, OnFadeOutTimer);
				mTimer = null;
			}
		}

		private var mIsMuted : Boolean = false;
		private var mTimer : Timer;
		private var mMusic : Sound = null;
		private var mMusicSoundChannel : SoundChannel = null;
	}
}