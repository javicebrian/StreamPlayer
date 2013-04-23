package com.extreamr.streamplayer.controls
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.events.FlexEvent;
	
	import org.osmf.events.TimeEvent;
	import org.osmf.utils.*;
	
	import spark.components.mediaClasses.MuteButton;
	import spark.components.mediaClasses.ScrubBar;
	import spark.components.mediaClasses.VolumeBar;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	import spark.components.supportClasses.ToggleButtonBase;
	import spark.events.TrackBaseEvent;
	
	
	//--------------------------------------
	//  Events
	//--------------------------------------	
	
	/**
	 *  Dispatched when the <code>playPauseButton</code> is pressed.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="togglePlayPause", type="flash.events.Event")]
	/**
	 *  Dispatched when the <code>playStopButton</code> is pressed.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="togglePlayStop", type="flash.events.Event")]
	/**
	 *  Dispatched when the <code>fullScreenButton</code> is pressed.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="toggleFullscreen", type="flash.events.Event")]
	/**
	 *  Dispatched when the <code>muteButton</code> is pressed.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="toggleMuted", type="flash.events.Event")]
	/**
	*  Dispatched when the <code>playButtons</code> is pressed.
	* 
	* @eventType flash.events.Event
	*/
	[Event(name="play", type="flash.events.Event")]
	/**
	 *  Dispatched when the <code>pause</code> is pressed.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="pause", type="flash.events.Event")]
	/**
	 *  Dispatched when the <code>volume</code> change.
	 * 
	 * @eventType flash.events.Event
	 */
	[Event(name="volumeChange", type="flash.events.Event")]
	/**
	 *  Dispatched when the <code>scrubBar</code> change the value with the value in time.
	 * 
	 * @eventType org.osmf.events.TimeEvent
	 */
	[Event(name="seek", type="org.osmf.events.TimeEvent")]
	
	//--------------------------------------
	//  SkinStates
	//--------------------------------------
	
	/**
	 *  normal state of the Controls
	 * 	when plays VOD.
	 */
	[SkinState("normal")]
	
	/**
	 *  fullScreen state of the Controls 
	 *  when is necesary.
	 */
	[SkinState("fullScreen")]	
	
	/**
	 *  normal state of the Controls 
	 */
	[SkinState("live")]	
	
	/**
	 *  live state of the Controls 
	 *  when fullscreen.
	 */
	[SkinState("liveAndFullScreen")]	
	
	public class Controls extends SkinnableComponent
	{
		
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		public static const TOGGLE_PLAY_PAUSE:String = "togglePlayPause";
		public static const TOGGLE_PLAY_STOP:String = "togglePlayStop";
		public static const TOGGLE_FULLSCREEN:String = "toggleFullscreen";
		public static const TOGGLE_MUTED:String = "toggleMuted";
		public static const SEEK:String = "seek";
		public static const PLAY:String = "play";
		public static const PAUSE:String = "pause";
		public static const VOLUME:String = "volumeChange";
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		[Bindable] public var skinState:String = "normal";
		[Bindable] public var dock:Boolean = true;
		protected var _muted:Boolean = false;
		protected var _volume:Number = 1;
		protected var _playStateBeforeScrub:Boolean;
		protected var _playing:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		
		public function Controls()
		{
			super();
		}
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part to display the current value of <code>codecurrentTime</code>.
		 */
		public var currentTimeDisplay:TextBase;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for a button to toggle fullscreen mode.
		 */
		public var fullScreenButton:ToggleButtonBase;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for the mute button.  The mute 
		 *  button has both a <code>muted</code> property and a 
		 *  <code>volume</code> property.
		 */
		public var muteButton:MuteButton;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for a play/pause button.  When the 
		 *  video is playing, the <code>selected</code> property is set to 
		 *  <code>true</code>.  When the video is paused or stopped, 
		 *  the <code>selected</code> property is set to <code>false</code>.
		 */
		public var playPauseButton:ToggleButtonBase;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for a play/stop button.  When the 
		 *  video is playing, the <code>selected</code> property is set to 
		 *  <code>true</code>.  When the video is paused or stopped, 
		 *  the <code>selected</code> property is set to <code>false</code>.
		 */
		public var playStopButton:ToggleButtonBase;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for the scrub bar (the 
		 *  timeline).
		 */
		public var scrubBar:ScrubBar;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for the stop button.
		 */
		public var stopButton:ButtonBase;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part to display the duration.
		 */
		public var durationDisplay:TextBase;
		
		[SkinPart(required="false")]
		/**
		 *  An optional skin part for the volume control.
		 */
		public var volumeBar:VolumeBar;
		
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == playPauseButton)
			{
				playPauseButton.addEventListener(MouseEvent.CLICK,playPauseButton_clickHandler);
			}
			else if (instance == playStopButton)
			{
				playStopButton.addEventListener(MouseEvent.CLICK,playStopButton_clickHandler);
			}
			else if (instance == fullScreenButton)
			{
				fullScreenButton.addEventListener(MouseEvent.CLICK,fullScreenButton_clickHandler);
			}
			else if (instance == muteButton)
			{
				muteButton.addEventListener(MouseEvent.CLICK,onToggleMuted);
			}
			else if (instance == volumeBar)
			{
				volumeBar.maximum = 1;
				volumeBar.minimum = 0;
				volumeBar.value = volume;
				volumeBar.addEventListener(MouseEvent.CLICK,onToggleMuted);
				volumeBar.addEventListener(Event.CHANGE ,onVolumeBarChange);
			}
			else if (instance == scrubBar)
			{				
				// add thumbPress and thumbRelease so we can pause the video while dragging
				scrubBar.addEventListener(TrackBaseEvent.THUMB_PRESS, scrubBar_thumbPress);
				scrubBar.addEventListener(TrackBaseEvent.THUMB_RELEASE, scrubBar_thumbRelease);
				
				// add change to actually seek() when the change is complete
				scrubBar.addEventListener(Event.CHANGE, onScrubBarChange);
				
			}
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		private function playPauseButton_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event(TOGGLE_PLAY_PAUSE));
			
		}
		/**
		 *  @private
		 */
		private function playStopButton_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event(TOGGLE_PLAY_STOP));
			
		}
		/**
		 *  @private
		 */
		private function fullScreenButton_clickHandler(event:MouseEvent):void
		{
			dispatchEvent(new Event(TOGGLE_FULLSCREEN));
		}
		/**
		 *  @private
		 */
		private function onToggleMuted(event:MouseEvent):void
		{
			muted = event.target.muted;
		}
		/**
		 *  @private
		 */
		private function onVolumeBarChange(event:Event):void
		{
			volume = event.target.value;
		}
		
		/**
		 *  @private
		 */
		protected function onScrubBarChange(event:Event):void
		{
			dispatchEvent(new TimeEvent(SEEK,false,false,scrubBar.value));
		}
		
		/**
		 *  @private
		 */
		protected function scrubBar_thumbPress(event:TrackBaseEvent):void
		{
			_playStateBeforeScrub = _playing;
			
			if(_playStateBeforeScrub)
				dispatchEvent(new Event(PAUSE));
		}
		
		/**
		 *  @private
		 */
		protected function scrubBar_thumbRelease(event:TrackBaseEvent):void
		{
			if(_playStateBeforeScrub)
				dispatchEvent(new Event(PLAY));
		}
		
		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------
		/**
		 *  @public
		 */
		public function set playing(value:Boolean):void
		{
			if(playPauseButton)
				playPauseButton.selected = value;
			if(playStopButton)
				playStopButton.selected = value;
			
			_playing = value;
		}
		/**
		*  @public
		*/
		public function set fullScreen(value:Boolean):void
		{
			if(fullScreenButton)
				fullScreenButton.selected = value;
		}
		/**
		 *  @public
		 */
		public function set duration(value:Number):void
		{
			if(value<0)
				value = 0;
			if(durationDisplay)
				durationDisplay.text = TimeUtil.formatAsTimeCode(value);
			if(scrubBar)
				scrubBar.maximum = value;
		}
		/**
		 *  @public
		 */
		public function set currentTime(value:Number):void
		{
			if(value<0)
				value = 0;
			
			if(currentTimeDisplay)
				currentTimeDisplay.text = TimeUtil.formatAsTimeCode(value);
			if(scrubBar)
				scrubBar.value = value;
		}	
		/**
		 *  @public
		 */
		public function set bytesLoaded(value:Number):void
		{
			scrubBar.loadedRangeEnd = value;
		}	
		/**
		 *  @public
		 */
		public function set bytesTotal(value:Number):void
		{
			scrubBar.loadedRangeEnd = value;
		}	
		/**
		 *  @public
		 */
		public function set live(value:Boolean):void
		{
			(value)?skinState='live':skinState='normal';
		}	
		
		/**
		 *  @copy com.extreamr.streamplayer.controls#volume
		 * 
		 *  @default 1
		 */
		[Bindable(event="volumeChange")]
		public function get volume():Number
		{
			return _volume;
		}
		public function set volume(value:Number):void
		{
			if( _volume !== value)
			{
				_volume = value;
				if(muteButton)
					muteButton.volume = value;
				if(volumeBar)
					volumeBar.value = value;
				dispatchEvent(new Event(VOLUME));
			}
		}	
		
		/**
		 *  @copy com.extrearmr.streamplayer.controls#muted
		 * 
		 *  @default false
		 */
		[Bindable(event="toggleMuted")]
		public function get muted():Boolean
		{
			return _muted;
		}

		public function set muted(value:Boolean):void
		{
			if( _muted !== value)
			{
				_muted = value;
				if(muteButton)
					muteButton.muted = value;
				if(volumeBar)
					volumeBar.muted = value;
				dispatchEvent(new Event(TOGGLE_MUTED));
			}
		}


	}
}