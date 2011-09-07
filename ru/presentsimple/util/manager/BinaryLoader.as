package ru.presentsimple.util.manager 
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.utils.ByteArray;
	
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.display.LoaderInfo;
	
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public class BinaryLoader
	{
		private var _bidings:Array;
		private var _callBack:Function;
		private var _content:DisplayObject;
		
		public function BinaryLoader() 
		{
			
		}
		
		public function set bindings (arr:Array) :void {
			_bidings = arr;
		}
		
		public function get bindings () :Array {
			return _bidings;
		}
		
		public function load (data:ByteArray, callBack:Function) :void {
			_callBack = callBack;
			var loader:Loader = new Loader ();
			configureListeners (loader);
			loader.loadBytes (data);
		}
		
		private function configureListeners (loader:Loader) :void {
			loader.contentLoaderInfo.addEventListener (Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.addEventListener (IOErrorEvent.IO_ERROR, onIOError);
			loader.contentLoaderInfo.addEventListener (SecurityErrorEvent.SECURITY_ERROR, onSecurity);
			//  //loader.contentLoaderInfo.addEventListener ();
		}
		
		private function destroyListeners (loader:Loader) :void {
			loader.contentLoaderInfo.removeEventListener (Event.COMPLETE, onComplete);
			loader.contentLoaderInfo.removeEventListener (IOErrorEvent.IO_ERROR, onIOError);
			loader.contentLoaderInfo.removeEventListener (SecurityErrorEvent.SECURITY_ERROR, onSecurity);
		}
		
		private function onComplete (e:Event) :void {
			var loader:Loader = (e.target as LoaderInfo).loader;
			destroyListeners (loader);
			_content = loader.content;
			_callBack (this);
		}
		
		private function onIOError (e:IOErrorEvent) :void {
			trace (e.text);
		}
		
		private function onSecurity (e:SecurityErrorEvent) :void {
			trace (e.text);
		}
		
		public function get content () :DisplayObject {
			return _content;
		}
		
	}

}