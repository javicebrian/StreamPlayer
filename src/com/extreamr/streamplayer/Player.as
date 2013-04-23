package com.extreamr.streamplayer
{
	import com.extreamr.streamplayer.controls.Controls;
	import com.extreamr.streamplayer.display.Display;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElementContainer;
	import mx.managers.PopUpManager;
	
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.events.TimeEvent;
	import org.osmf.utils.*;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.events.TrackBaseEvent;
	
	//--------------------------------------
	//  Events
	//--------------------------------------	
	
	/**
	 *  Dispatched when the <code>Display.mediaPlayer</code> property of the MediaPlayer has changed.
	 *
	 * @eventType org.osmf.events.TimeEvent
	 **/
	[Event(name="dateInjection",type="org.osmf.events.TimeEvent")]
	/**
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
	 *  Dispatched when toggle between normal and fullScreen.
	 * 
	 *  @eventType flash.events.Event
	 */ 
	[Event(name="toggleFullscreen", type="flash.events.Event")]
	/**
	 *  Dispatched when toggle between vod and live.
	 * 
	 *  @eventType flash.events.Event
	 */ 
	[Event(name="toggleLive", type="flash.events.Event")]
	/**
	 *  Dispatched when switch between diferents bitrates.
	 * 
	 *  @eventType flash.events.Event
	 */ 
	[Event(name="switchBitrate", type="flash.events.Event")]
	
	//--------------------------------------
	//  SkinStates
	//--------------------------------------
	
	/**
	 *  Ready state of the Player.
	 *  The media is ready to be played.
	 */
	[SkinState("ready")]
	
	/**
	 *  Ready state of the Player when 
	 *  in full screen mode.  The media is ready to be played.
	 */
	[SkinState("readyAndFullScreen")]	
	
	
	/**
	 *  The Player control is a skinnable player that supports
	 *  progressive download, multi-bitrate streaming, streaming, etc.
	 *  
	 * <p>It supports playback of the following media files:</p> 
	 * <ul>
	 * 	<li>Streaming video (FLV, F4V, MP4, MPEG-4, MP4, M4V, F4F, 3GPP)</li>
	 * 	<li>Progressive audio (mp3)</li>
	 * 	<li>Progressive video (FLV, F4V, MP4, MP4V-ES, M4V, 3GPP, 3GPP2, QuickTime/MOV)</li>
	 * 	<li>Images (PNG, GIF, JPG)</li>
	 *  <li>SWF files</li>
	 * 	<li>F4M manifest files</li>
	 *  <li>Limited support for streaming audio (mp3, AAC, Speex, Nellymoser)</li>
	 * </ul>
	 *  The Player control contains a full-featured UI for controlling media playback.
	 * 
	 *  <p>The Player control has the following default characteristics: //TODO</p>
	 *     <table class="innertable">
	 *        <tr>
	 *           <th>Characteristic</th>
	 *           <th>Description</th>
	 *        </tr>
	 *        <tr>
	 *           <td>Default size</td>
	 *           <td>263 pixels wide by 184 pixels high</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Minimum size</td>
	 *           <td>0</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Maximum size</td>
	 *           <td>10000 pixels wide and 10000 pixels high</td>
	 *        </tr>
	 *        <tr>
	 *           <td>Default skin class</td>
	 *           <td> --- </td>
	 *        </tr>
	 *     </table>
	 *
	 *  @see com.streamuk.streamplayer.controls.Controls
	 *  @see com.streamuk.streamplayer.display.Display
	 *
	 *  @mxml
	 *
	 *  <p>The <code>&lt;streamplayer:Player&gt;</code> implements the following tag attributes:</p>
	 *
	 *  <pre>
	 *  &lt;streamplayer:Player
	 
	 *    <strong>Properties</strong>
	 *    fullScreen="false"
	 *    live="true"
	 *    skinState="normal"
	 *    source=""
	 *    skinClass=""
	 *  
	 *    <strong>Events</strong>
	 *    complete="<i>No default</i>"
	 *    currentTimeChange="<i>No default</i>"
	 *    mediaPlayerStateChange="<i>No default</i>"
	 *    switchBitrate="<i>No default</i>"
	 *    toggleFullscreen="<i>No default</i>"
	 *    toggleLive="<i>No default</i>"
	 *  
	 * 
	 *  /&gt;
	 *  </pre>
	 *
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4.5
	 */
	public class Player extends SkinnableComponent
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		public static const TOGGLE_PLAY_PAUSE:String = "togglePlayPause";
		public static const TOGGLE_FULLSCREEN:String = "toggleFullscreen";
		public static const TOGGLE_LIVE:String = "toggleLive";
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var _fullScreen:Boolean = false;
		protected var _live:Boolean = false;
		protected var _startTime:Number = 1302083513345;
		protected var _source:*;
		protected var oldProperties:Object;
		[Bindable]public var skinState:String  = "ready";;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 */
		public function Player()
		{
			super();
		}
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		[SkinPart(required="true")]
		
		/**
		 *  A required skin part that defines the Display.
		 *  
		 */
		public var display:Display;	
		
		[SkinPart(required="true")]
		
		/**
		 *  A required skin part that defines the Display.
		 *  
		 */
		public var controls:Controls;
		
		
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
			
			if (instance == display)
			{
				setupDisplay()
			}
			if (instance == controls)
			{
				setupControls()
			}
		}
		//----------------------------------
		//  display
		//----------------------------------
		protected function setupDisplay():void
		{
			display.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onMediaPlayerStateChange)
			display.addEventListener(TimeEvent.DURATION_CHANGE, onDurationChange)
			display.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onCurrentTimeChange);
			display.addEventListener(Display.DATE_INJECTION, onDateInjection);
			display.addEventListener(Display.SWITCH_BITRATE, onSwitchBitrate);
			
			if(_source)
				display.source = _source;
		}
		
		protected function onMediaPlayerStateChange(event:MediaPlayerStateChangeEvent):void
		{
			try
			{
				controls.playing = display.playing;
			}catch(e:Error){};
			dispatchEvent(event);
		}
		
		protected function onDurationChange(event:TimeEvent):void
		{
			if(live) return;
			if(!controls) return;
			controls.duration = event.time;
			dispatchEvent(event);
		}
		
		protected function onCurrentTimeChange(event:TimeEvent):void
		{
			if(live && _startTime) return;
			controls.currentTime = event.time;
			dispatchEvent(event);
		}
		
		protected function onDateInjection(event:TimeEvent):void
		{
			dispatchEvent(event);
			
			if(!live || !_startTime) return;
			controls.currentTime = (event.time-_startTime)/1000;
			
			dispatchEvent(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE,false,false,event.time));
			
			//TODO delay control
//			var v:int = (event.time - new Date().time)/1000*-1;
//			trace(TimeUtil.formatAsTimeCode(v));
			
		}
		
		protected function onSwitchBitrate(event:Event):void
		{
			
			dispatchEvent(event);
			
		}
		
		
		//----------------------------------
		//  controls
		//----------------------------------
		protected function setupControls():void
		{
			controls.addEventListener(Controls.TOGGLE_PLAY_PAUSE, onTogglePlayPause);
			controls.addEventListener(Controls.TOGGLE_PLAY_STOP, onTogglePlayStop);
			controls.addEventListener(Controls.SEEK, onSeek);
			controls.addEventListener(Controls.PLAY, onPlay);
			controls.addEventListener(Controls.PAUSE, onPause);
			controls.addEventListener(Controls.TOGGLE_FULLSCREEN, onFullScreen);
			controls.addEventListener(Controls.TOGGLE_MUTED, onMuted);
			controls.addEventListener(Controls.VOLUME, onVolume);
			
		}
		
		protected function onTogglePlayPause(event:Event):void
		{
			display.togglePlayPause();
		}
		protected function onTogglePlayStop(event:Event):void
		{
			display.togglePlayStop();
		}
		
		protected function onSeek(event:TimeEvent):void
		{
			display.seek(event.time);
		}
		
		protected function onPlay(event:Event):void
		{
			display.play();
		}
		
		protected function onPause(event:Event):void
		{
			display.pause();
		}
		
		/**
		 *  @private
		 */
		protected function onMuted(event:Event):void
		{
			display.muted = event.target.muted; 
		}
		
		/**
		 *  @private
		 */
		protected function onVolume(event:Event):void
		{
			display.volume = event.target.volume; 
		}
		
		/**
		 *  @private
		 */
		protected function onFullScreen(event:Event):void
		{
			if (!fullScreen)
			{
				// check to make sure we can go into fullscreen mode
				if (!systemManager.getTopLevelRoot())
					return;
				
				fullScreen = true;
				
				oldProperties = {parent: this.parent,
					x: this.x,
					y: this.y,
					explicitWidth: this.explicitWidth,
					explicitHeight: this.explicitHeight};
				
				if (parent is IVisualElementContainer)
				{
					var ivec:IVisualElementContainer = IVisualElementContainer(parent);
					oldProperties.childIndex = ivec.getElementIndex(this);
					ivec.removeElement(this);
				}
				else
				{
					oldProperties.childIndex = parent.getChildIndex(this);
					parent.removeChild(this);
				}
				
				// add as a popup
				PopUpManager.addPopUp(this, FlexGlobals.topLevelApplication as DisplayObject);
				
				setLayoutBoundsSize(flash.system.Capabilities.screenResolutionX, flash.system.Capabilities.screenResolutionY, true);
				// set the explicit width/height to make sure this value sticks regardless 
				// of any other code or layout passes.  Calling setLayoutBoundsSize() before hand
				// allows us to use postLayout width/height
				this.explicitWidth = width;
				this.explicitHeight = height;
				setLayoutBoundsPosition(0, 0, true);
				
				systemManager.stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
				
				// TODO (rfrishbe): Should we make this FULL_SCREEN_INTERACTIVE if in AIR?
				systemManager.stage.displayState = StageDisplayState.FULL_SCREEN;
				dispatchEvent(new Event(TOGGLE_FULLSCREEN));
				
				skinState = "readyAndFullScreen";
				controls.fullScreen = true;
				
			}
			else
			{
				systemManager.stage.displayState = StageDisplayState.NORMAL;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------
		/**
		 *  @public
		 */
		public function get source():*
		{
			return display.source;	
		}
		
		public function set source(value:*):void
		{
			_source = value;
			
			if(display)
				display.source = value;
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
			return display.playing;	
		}
		
		//----------------------------------
		//  fullScreen
		//----------------------------------
		[Inspectable(category="General")]
		[Bindable("toggleFullscreen")]
		
		/**
		 *  Contains <code>true</code> if the video is fullscreen.
		 * 
		 * 	@default false
		 */
		public function get fullScreen():Boolean
		{
			return _fullScreen;
		}
		
		public function set fullScreen(value:Boolean):void
		{
			_fullScreen = value;
		}
		
		//----------------------------------
		//  live
		//----------------------------------
		[Inspectable(category="General")]
		[Bindable("toggleLive")]
		
		/**
		 *  Contains <code>true</code> if the video is live.
		 * 
		 * 	@default false
		 */
		public function get live():Boolean
		{
			return _live;
		}
		
		public function set live(value:Boolean):void
		{
			_live = value;
			dispatchEvent(new Event(TOGGLE_LIVE));
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 *  Handles when coming out the full screen mode
		 */
		private function fullScreenEventHandler(event:FullScreenEvent):void
		{
			// going in to full screen is handled by the 
			// fullScreenButton_clickHandler
			if (event.fullScreen)
				return;
			
			// set the fullScreen variable back to false and remove this event listener
			fullScreen = false;
			systemManager.stage.removeEventListener(FullScreenEvent.FULL_SCREEN, fullScreenEventHandler);
			
			// reset it so we're re-included in the layout
			this.x = oldProperties.x;
			this.y = oldProperties.y;
			this.explicitWidth = oldProperties.explicitWidth;
			this.explicitHeight = oldProperties.explicitHeight;
			
			// remove from top level application:
			PopUpManager.removePopUp(this);
			
			// add back to original parent
			if (oldProperties.parent is IVisualElementContainer)
				oldProperties.parent.addElementAt(this, oldProperties.childIndex);
			else
				oldProperties.parent.addChildAt(this, oldProperties.childIndex);
			
			dispatchEvent(new Event(TOGGLE_FULLSCREEN));
			skinState = "ready";
			controls.fullScreen = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  External functions
		//
		//--------------------------------------------------------------------------
		/**
		 *  @private
		 *  Handles when coming out the full screen mode
		 */
		public function stop():void
		{
			if(playing)
				display.stop();
		}
		
		public function play():void
		{
			if(!playing)
				display.play();
		}
		

	}
}