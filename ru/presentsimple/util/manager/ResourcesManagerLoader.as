package ru.presentsimple.util.manager 
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import by.blooddy.crypto.serialization.JSON;
	import flash.display.Sprite;
	
	import ru.presentsimple.util.manager.ResourceURLLoader;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public class ResourcesManagerLoader
	{
		private static var _instance:ResourcesManagerLoader = null;
		
		private var simultaneouslyCof:int;
		
		private var _loadings:Array;
		private var _bindings:Object;
		
		private var _proccessLoadings:Array;
		
		private var completeFunction:Function;
	
		// обязательный метод Singleton
		public static function getInstance():ResourcesManagerLoader
		{
			if ( _instance == null )
			{
				_instance = new ResourcesManagerLoader();
			}
			return _instance;
		}
		
		// Конструктор
		public function ResourcesManagerLoader() 
		{
			
			//m_timerRepeat = new flash.utils.Timer(500, 1);
            //m_timerRepeat.addEventListener(flash.events.TimerEvent.TIMER_COMPLETE, processQueue);
		}
		
		public function load (simultaneously:int = 1, pause:int = 0) :void {
			
			//todo придумать более однозначное название для переменной коэфициента одновремменой загрузки
			// ?! max_loadings 
			// ?! parallel cof
				simultaneouslyCof = simultaneously;
			
			// todo отложенная по таймеру загрузка
			
			_loadings = ResourcesManager.list.getLoadings().concat();
			
			releaseBindings (_loadings);
			
			//trace (_loadings);
			//if (pause > 0) {
				//_delayLoadNext (pause);
			//} else {
					_loadNext ();
			//}
		}
		
		private function releaseBindings (loadings:Array) :void {
			if (_bindings == null) {
				_bindings = new Object ();
			}
			
			for (var instance:int = 0; instance < loadings.length; instance ++) {
				
				var resource:IResource = loadings[instance] as IResource
				var uid:String = resource.uid; 
				if (_bindings[uid] == null) _bindings[uid] = [];
				_bindings[uid].push (resource);
				
				if (_bindings[uid].length > 1) {
					var index:int = loadings.indexOf (resource);
					loadings.splice (index, 1);
				}
			}
		}
		
		private function _loadNext () :void {
			if (_proccessLoadings == null) {
				_proccessLoadings = new Array ();
			}
			
			if (_proccessLoadings.length < simultaneouslyCof && _loadings.length != 0) {
				
				var resource:IResource = _loadings.shift() as IResource;
				
				_proccessLoadings.push (resource);
				_loadResource (resource);
				
				_loadNext ();
			} 
		}
		
		private function _loadResource (resource:IResource) :void {
			
			var uid:String = resource.uid;
			var uidBindings:Array = _bindings[uid];
			
			if (uidBindings.length > 1) {
				for (var instance:int = 0; instance < uidBindings.length; instance ++ ) {
					var bindingResource:IResource = uidBindings[instance];
					bindingResource.status = ResourceLoadingStatus.LOADING_PROGRESS;
				}
			} else {
				resource.status = ResourceLoadingStatus.LOADING_PROGRESS;
			}
			
			var loader:ResourceURLLoader = new ResourceURLLoader ();
			configureListeners (loader);
			
			var request:URLRequest = new URLRequest (resource.uid);
			
			switch (resource.type.toLowerCase()) {
				case ResourceType.BITMAP: 
				case ResourceType.MOVIECLIP:
				case ResourceType.SPRITE:
				case ResourceType.BINARY:
				case ResourceType.BITMAP_DATA:
				case ResourceType.SOUND:
				{
					loader.dataFormat = URLLoaderDataFormat.BINARY;			
					break;
				}
				case 'xml':
				case 'json':
				{
					request.method = resource.method;
					request.data = resource.params;
					loader.dataFormat = URLLoaderDataFormat.TEXT;
					break;
				}
				default: 
				{
					throw new Error ('Error in ResourcesManagerLoader::_loadResource uknown resourse type, in resource:' + resource);
				}
			}
			
			loader.uid = resource.uid;
			loader.load (request);
		}
		
		private function configureListeners (loader:*) :void {
			loader.addEventListener (Event.COMPLETE, onComplete);
			loader.addEventListener (SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener (IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function destroyListeners (loader:*) :void {
			loader.removeEventListener (Event.COMPLETE, onComplete);
			loader.removeEventListener (SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.removeEventListener (IOErrorEvent.IO_ERROR, onIOError);
		}
		
		private function onComplete (e:Event) :void {
			destroyListeners(e.target);
			
			var uid:String;
			var bindings:Array;
			
			var loader:ResourceURLLoader = e.target as ResourceURLLoader;
						
			uid = loader.uid;
			bindings = _bindings[uid] as Array;
			
			if (loader.dataFormat == URLLoaderDataFormat.TEXT) {
				transformBindings (bindings, loader.data);
			} 
			
			
			if (loader.dataFormat == URLLoaderDataFormat.BINARY) {
				var binaryLoader:BinaryLoader = new BinaryLoader ();
				binaryLoader.bindings = bindings;
				binaryLoader.load (loader.data, onBinaryLoad);
			}
						
			
		}
		
		private	function onBinaryLoad (binaryLoader:BinaryLoader) :void 
		{
			transformBindings (binaryLoader.bindings, binaryLoader.content);
			binaryLoader = null;
		}
		
		private function transformBindings (bindings:Array, data:*) :void {
			for (var instance:int = 0; instance < bindings.length; instance ++ )
			{
				var resource:IResource = bindings[instance]; 
				var uid:String = resource.uid;
				
				resource.status = ResourceLoadingStatus.LOADING_COMPLETE;
									
				var classObject:* = convertToType (resource.type, data);
				
									
				ResourcesManager.cache.addSource (uid, resource.name, classObject);
				resource.source = ResourcesManager.cache.getSource(uid);
				
				var index:int;
				index = _proccessLoadings.indexOf (resource);
				if (index != -1) _proccessLoadings.splice (index, 1);
			}
			
			if (_loadings.length) {
				_loadNext ();
			} else if (!_proccessLoadings.length) {
				callBackFunction (Event.COMPLETE);
			}
			
			//dispatchEvent (new ResourcesEvent (ResourcesEvent.DATA_LOADED));
		}
		
		
				
		private function onIOError (e:IOErrorEvent) :void {
			trace (e.text)
		}
		
		private function onSecurityError (e:SecurityErrorEvent) :void {
			trace (e.text);
		}
		
		public function addEventListener (type:String, callBack:Function) :void {
			switch (type) {
				case Event.COMPLETE:
				{
					completeFunction = callBack;
					break;
				}
			}
		}
		
		public function removeEventListener (type:String) :void {
			switch (type) {
				case Event.COMPLETE:
				{
					completeFunction = null;
					break;
				}
			}
		}
		
		private function callBackFunction (type:String) :void {
			switch (type) {
				case Event.COMPLETE :
				{
					if (completeFunction != null) completeFunction (new Event(type));
				}
			}
		}
		
		//private function convertToType (data:*, type:String) :* {
			//if (type is Bitmap) 
			//{
				//var loader:Loader = new Loader ();
				//loader.addEventListener (Event.COMPLETE, onComplete);
				//loader.loadBytes (data);
				
				//return  (loader.content) as Bitmap;
				
				
			//}
		//}
		
		private function convertToType (type:String, data:*) :* {
			
			switch (type.toLowerCase()) {
				case ResourceType.BITMAP:
				{
					return data as Bitmap;
				}
				case ResourceType.MOVIECLIP:
				{
					return  data as MovieClip
				}
				case ResourceType.SPRITE:
				{
					return data as Sprite;
				}
				case ResourceType.JSON:
				{
					return JSON.decode (data);
				}
				case ResourceType.XML:
				{
					return new XML(data);
				}
				case ResourceType.BINARY:
				{
					return data;
				}
				case ResourceType.BITMAP_DATA:
				{
					return data.bitmapData as BitmapData;
				}
				default:
				{
					throw new Error ('Error in Resource::convertToType. Uknown type of resource');
				}
				
			}
		}
	}

}