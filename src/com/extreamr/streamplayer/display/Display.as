package com.extreamr.streamplayer.display
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.NetStream;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.controls.Alert;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	
	import org.osmf.containers.MediaContainer;
	import org.osmf.elements.LightweightVideoElement;
	import org.osmf.elements.VideoElement;
	import org.osmf.events.DisplayObjectEvent;
	import org.osmf.events.DynamicStreamEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerCapabilityChangeEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.SeekEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.DefaultMediaFactory;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaFactory;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.media.URLResource;
	import org.osmf.net.DynamicStreamingItem;
	import org.osmf.net.DynamicStreamingResource;
	import org.osmf.net.StreamingURLResource;
	import org.osmf.traits.DynamicStreamTrait;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.PlayTrait;
	import org.osmf.utils.*;

	//--------------------------------------
	//  Events
	//--------------------------------------	
	
	/**
	 *  Dispatched when the <code>duration</code> property of the media has changed.
	 * 
	 *  <p>This event may not be dispatched when the source is set to null or a playback
	 *  error occurs.</p>
	 * 
	 * @eventType org.osmf.events.TimeEvent.DURATION_CHANGE
	 */
	[Event(name="durationChange", type="org.osmf.events.TimeEvent")]
	/**
	 *  Dispatched when the <code>currentTime</code> property of the MediaPlayer has changed.
	 * 
	 *  <p>This event may not be dispatched when the source is set to null or a playback
	 *  error occurs.</p>
	 *
	 * @eventType org.osmf.events.TimeEvent.CURRENT_TIME_CHANGE
	 **/
	[Event(name="currentTimeChange",type="org.osmf.events.TimeEvent")]
	/**
	 *  Dispatched when the <code>mediaPlayer</code> property of the MediaPlayer has changed.
	 *
	 * @eventType org.osmf.events.TimeEvent
	 **/
	[Event(name="dateInjection",type="org.osmf.events.TimeEvent")]
	/**
	 *  Dispatched when the playhead reaches the duration for playable media.
	 * 
	 *  @eventType org.osmf.events.TimeEvent.COMPLETE
	 */  
	[Event(name="complete", type="org.osmf.events.TimeEvent")]
	/**
	 *  Dispatched when the MediaPlayer's state has changed.
	 * 
	 *  @eventType org.osmf.events.MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE
	 */ 
	[Event(name="mediaPlayerStateChange", type="org.osmf.events.MediaPlayerStateChangeEvent")]
	/**
	 *  Dispatched when switch between diferents bitrates.
	 * 
	 *  @eventType flash.events.Event
	 */ 
	[Event(name="switchBitrate", type="flash.events.Event")]
	
	/**
	 * Display extends an OSMF MediaContainer including all the
	 * video functionallity.
	 **/	
	public class Display extends MediaContainerUIComponent
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		public static const DATE_INJECTION:String = "dateInjection";
		public static const SWITCH_BITRATE:String = "switchBitrate";
		private static const DEFAULT_PROGRESS_DELAY:uint = 100;
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**OSMF stuff*/
		protected var mediaPlayer:MediaPlayer;
		protected var mediaFactory:DefaultMediaFactory;
		//protected var mediaElement:LightweightVideoElement;
		protected var mediaElement:MediaElement;
		protected var resource:StreamingURLResource;
		protected var dynamicStreamResource:DynamicStreamingResource;
		
		/*
		 * Read only variables
		 * TODO create events
		 */
		protected var _state:String;
		
		/*
		 * 'PUBLICs' variables with get/set
		 */
		protected var _source:String;
		protected var _scaleMode:String = ScaleMode.LETTERBOX;
		protected var _muted:Boolean = false;
		protected var _volume:Number = 100;
		
		/**
		 * PUBLICs variables
		 */
		public var autoPlay:Boolean = false;
		public var loop:Boolean = false;
		
		
		
		/*
		 * TEMPORAL
		 */
		private static const MAX_VIDEO_WIDTH:int = 640;
		private static const MAX_VIDEO_HEIGHT:int = 390;
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function Display()
		{
			super();
			
			container = new MediaContainer();
			mediaFactory = new DefaultMediaFactory();
			mediaPlayer = new MediaPlayer();
			
			setMediaPlayer();
			
			//DropBox.instance.addEventListener(DropBoxEvent.METADATA_INJECTION,onDateInjection);
			
			var square:Sprite = new Sprite();
			square.graphics.beginFill(0xFF0000);
			square.graphics.drawRect(0, 0,width, height);
			addChild(square);
			
			this.mask = square;
			
			this.addEventListener(ResizeEvent.RESIZE,onResize);
		}
		
		protected function onResize(event:ResizeEvent):void
		{
			
			if(this.mask)
				this.removeChild(this.mask)
			
			var square:Sprite = new Sprite();
			square.graphics.beginFill(0xFF0000);
			square.graphics.drawRect(0, 0,width, height);
			addChild(square);
			
			this.mask = square;
		}
		
		/*
		 * mediaPlayer stuff
		 * 
		*/
		protected function setMediaPlayer():void
		{
			mediaPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE, onMediaSizeChange);		
			mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, dispatchEvent);	
			mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, dispatchEvent);
			mediaPlayer.addEventListener(TimeEvent.COMPLETE, dispatchEvent); 
//			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onPlayingChange); not yet
			mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE, onIsDynamicStreamChange);
			mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onStateChange);
			mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			mediaPlayer.addEventListener(DynamicStreamEvent.SWITCHING_CHANGE, onDymChange);
			mediaPlayer.addEventListener(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE , onDymChange);
			mediaPlayer.addEventListener(SeekEvent.SEEKING_CHANGE , onFirstCanSeek);
			
			mediaPlayer.currentTimeUpdateInterval = DEFAULT_PROGRESS_DELAY;
		}
		
		protected function onFirstCanSeek(event:SeekEvent):void
		{				
			mediaPlayer.removeEventListener(SeekEvent.SEEKING_CHANGE , onFirstCanSeek);
			if(!autoPlay)
			{
				mediaPlayer.pause();
				mediaPlayer.seek(0);
			}
		}
		
		protected function onDymChange(event:DynamicStreamEvent):void
		{
			trace("change "+mediaPlayer.currentDynamicStreamIndex);
			dispatchEvent(new Event(SWITCH_BITRATE));
		}
		
		protected function onIsDynamicStreamChange(event:MediaPlayerCapabilityChangeEvent):void
		{
			trace("IsDynamicStreamChange");
		}
		
		
		/*
		 *  <b>TODO select between  scaleMode: Adjust, Zoom, Stretch, None</b>
		 * 	@see http://www.osmf.org/configurator/fmp/  
		 */	
		protected function onMediaSizeChange(event:DisplayObjectEvent):void 
		{
			
		/*	var newWidth:int = event.newWidth;
			var newHeight:int = event.newHeight;
			
			// Scale to native or smaller
			if (newWidth > MAX_VIDEO_WIDTH || newHeight > MAX_VIDEO_HEIGHT)
			{
				if ((newWidth/newHeight) >= (MAX_VIDEO_WIDTH/MAX_VIDEO_HEIGHT))
				{
					width = MAX_VIDEO_WIDTH;
					height = MAX_VIDEO_WIDTH * (newHeight/newWidth);
				}
				else
				{
					width = MAX_VIDEO_HEIGHT * (newWidth/newHeight);
					height = MAX_VIDEO_HEIGHT;
				}
			}
			else if (newWidth > 0 && newHeight > 0)
			{
				width = newWidth;
				height = newHeight;			
			}
			
			width = MAX_VIDEO_WIDTH;
			height = MAX_VIDEO_HEIGHT;*/
		}
		
		
		private function onStateChange(event:MediaPlayerStateChangeEvent):void
		{
			trace(" state=" + event.state);
			
			_state = event.state;
			
			switch (event.state)
			{
//				case MediaPlayerState.READY:
//					_mediaPlayerState = "Ready";
//					break;					
//				case MediaPlayerState.PLAYBACK_ERROR:
//					_mediaPlayerState = "Error";
//					break;
			}
			
			dispatchEvent(event);
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			trace("error ID="+event.error.errorID+" message="+event.error.message);
		}
		
		/**
		 * legacy for date injection 
		 * /
		private function onDateInjection(event:DropBoxEvent):void
		{
			var d:Date;

			try{
				d = event.pack.time;
				dispatchEvent(new TimeEvent(DATE_INJECTION,false,false,d.time));
			}catch(e:Error){trace(event.pack);}
		}*/
		
		/*
		 * mediaElement stuff
		 */
		private function setupMediaElementListeners(add:Boolean=true):void
		{
			if (mediaElement == null)
			{
				return;
			}
			
			if (add)
			{
				// Listen for traits to be added, so we can adjust the UI. For example, enable the seek bar
				// when the seekable trait is added
				mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
//				mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
//				mediaElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			}
			else
			{
				mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
//				mediaElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
//				mediaElement.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
			}
		}
		
		private var loadTrait:LoadTrait;
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			
			switch (event.traitType)
			{
				case MediaTraitType.SEEK:
					break;
				case MediaTraitType.LOAD:
					break;
				case MediaTraitType.BUFFER:
					break;
				case MediaTraitType.PLAY:
					loadTrait = mediaPlayer.media.getTrait( MediaTraitType.LOAD) as LoadTrait;
					break;
				case MediaTraitType.DYNAMIC_STREAM:
					break;
			}	
		}
		
		public function get netStream():NetStream
		{
			return Object(loadTrait).netStream;
		}
		
		private function setMediaElement(value:MediaElement):void
		{
			if (mediaPlayer.media != null)
			{
				container.removeMediaElement(mediaPlayer.media);
			}
			
			if (value != null)
			{
				container.addMediaElement(value);
			}
			
			mediaPlayer.media = value;
			
		}
		
		
		
		
		/**
		 *  Protected methods
		 */	
		protected function loadSource():void
		{
			//var me:MediaElement = mediaFactory.createMediaElement(source);
			//var me:MediaElement = mediaFactory.createMediaElement(r);
			
			mediaElement = mediaFactory.createMediaElement(source);
			//mediaElement = new LightweightVideoElement(me.resource);
			setupMediaElementListeners();
			
			if(mediaElement is VideoElement)
				VideoElement(mediaElement).smoothing = true;
			
			var layoutData:LayoutMetadata = new LayoutMetadata();
			layoutData.horizontalAlign = HorizontalAlign.CENTER;
			layoutData.verticalAlign = org.osmf.layout.VerticalAlign.MIDDLE;
			layoutData.scaleMode = _scaleMode;
			layoutData.percentWidth = 100;
			layoutData.percentHeight = 100;
			mediaElement.metadata.addValue(LayoutMetadata.LAYOUT_NAMESPACE, layoutData);
			
			
			setMediaElement(mediaElement);
			
		}
		
		
		/**
		 *  <b>Accepted types:</b></br> String, StreamingURLResource, DynamicStreamingResource
		 */		
		public function get source():*
		{
			if(dynamicStreamResource)
				return dynamicStreamResource;
			
			return resource;	
		}
		
		public function set source(value:*):void
		{
			if(value is DynamicStreamingResource)
			{
				dynamicStreamResource = value;
			}
			else if(value is StreamingURLResource)
			{
				resource = value;
			}
			else if(value is String)
			{
				resource = new StreamingURLResource(value);
				resource.urlIncludesFMSApplicationInstance = false;
			}
			else
				throw new Error("Type Coercion failed: just can convert from String, StreamingURLResource or DynamicStreamingResource");
			
			loadSource();
		}
		
		/**
		 *  Public methods
		 */
		public function play(url:String=null):void
		{
			if(url!=null)
			{
				_source = url;
				loadSource();
			}
			else if(mediaPlayer.canPlay)
			{
				mediaPlayer.play();
			}
			else
			{
				if(source)
					loadSource();
			}
			
		}
		
		public function pause():void
		{
			mediaPlayer.pause();
			trace('pause');
			
		}
		
		public function togglePlayPause():void
		{
			if(mediaPlayer.playing)
				pause();
			else
				play();
			
		}
		
		public function togglePlayStop():void
		{
			if(mediaPlayer.playing)
				stop();
			else
				play();
			
		}
		
		public function stop():void
		{
			setupMediaElementListeners(false);
			mediaPlayer.media = null;
//			alpha = MEDIA_PLAYER_UNLOADED_ALPHA; ¿?puede ser
		}
		
		public function seek(time:Number):void
		{
			
			if (mediaPlayer.canSeek)
			{
				mediaPlayer.seek(time); 
			}
		}

		
		//----------------------------------
		//  duration
		//----------------------------------
		[Inspectable(category="General")]
		[Bindable("durationChange")]
		
		/**
		 *  Contains <code>total time</code> of the video playing.
		 */
		public function get duration():Number
		{
			return mediaPlayer.duration;
		}
		
		//----------------------------------
		//  currentTime
		//----------------------------------
		[Inspectable(category="General")]
		[Bindable("currentTimeChange")]
		
		/**
		 *  Contains <code>current time</code> playing.
		 */
		public function get currentTime():Number
		{
			return mediaPlayer.currentTime;	
		}

		public function get state():String
		{
			return _state;	
		}
		
		//----------------------------------
		//  playing
		//----------------------------------
		[Inspectable(category="General")]
		[Bindable("mediaPlayerStateChange")]
		
		/**
		 *  Contains <code>true</code> if the video is playing or is attempting to play.
		 *  
		 *  <p>The video may not be currently playing, as it may be seeking 
		 *  or buffering, but the video is attempting to play.</p> 
		 */
		public function get playing():Boolean
		{
			return mediaPlayer.playing;	
		}
		
		
		//----------------------------------
		//  bytesLoaded
		//----------------------------------
		
		[Inspectable(Category="General", defaultValue="0")]
		[Bindable("bytesLoadedChange")]
		[Bindable("mediaPlayerStateChange")]
		
		/**
		 *  @copy spark.components.VideoDisplay#bytesLoaded
		 * 
		 *  @default 0
		 */
		public function get bytesLoaded():Number
		{
			if (mediaPlayer)
				return mediaPlayer.bytesLoaded;
			else
				return 0;
		}
		
		//----------------------------------
		//  bytesTotal
		//----------------------------------
		
		[Inspectable(Category="General", defaultValue="0")]
		[Bindable("mediaPlayerStateChange")]
		
		/**
		 *  @copy com.streamuk.streamplayer.display#bytesTotal
		 * 
		 *  @default 0
		 */
		public function get bytesTotal():Number
		{
			
			if (mediaPlayer)
				return mediaPlayer.bytesTotal;
			else
				return 0;
		}
		
		//----------------------------------
		//  scaleMode
		//----------------------------------
		/**
		 *  @copy com.streamuk.streamplayer.display#scaleMode
		 * 
		 *  @default ScaleMode.LETTERBOX
		 */
		public function get scaleMode():String
		{
			return _scaleMode;
		}

		public function set scaleMode(value:String):void
		{
			_scaleMode = value;
		}
		
		//----------------------------------
		//  muted
		//----------------------------------
		/**
		 *  @copy com.streamuk.streamplayer.display#muted
		 * 
		 *  @default false
		 */
		[Bindable(event="mutedChange")]
		public function get muted():Boolean
		{
			return _muted;
		}

		public function set muted(value:Boolean):void
		{
			if( _muted != value)
			{
				mediaPlayer.muted = value;
				_muted = value;
				dispatchEvent(new Event("mutedChange"));
			}
		}

		
		//----------------------------------
		//  volume
		//----------------------------------
		[Bindable(event="volumeChange")]
		public function get volume():Number
		{
			return _volume;
		}
		
		public function set volume(value:Number):void
		{
			if( _volume != value)
			{
				mediaPlayer.volume = value;
				_volume = value;
				dispatchEvent(new Event("volumeChange"));
			}
		}
		
		//----------------------------------
		//  currentStream
		//----------------------------------
		[Bindable(event="switchBitrate")]
		public function get currentStream():*
		{
			if(dynamicStreamResource)
				return dynamicStreamResource.streamItems[mediaPlayer.currentDynamicStreamIndex];
			else
				return resource;
		}
		
		public function set currentStream(value:*):void
		{
			return;
		}

		
	}
}