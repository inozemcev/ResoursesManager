package ru.presentsimple.util.manager 
{
	import flash.display.Bitmap;
	import flash.utils.ByteArray;
	import flash.display.MovieClip;
	import by.blooddy.crypto.serialization.JSON;
	import flash.net.URLRequestMethod;
	
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public class Resource implements IResource
	{
		private var _uid:String;
		private var _name:String;
		private var _type:String;
		private var _status:String;
		private var _source:*;
		private var _method:String;
		private var _params:Object;
				
		public function Resource(uid:String = 'not inited', type:String = 'bitmap', name:String = 'unknownName', 
								 params:Object = null, method:String = URLRequestMethod.GET) 
		{
			if (name != 'unknownName') _name = name else _name = ResourcesManager.uniqueName;
			_uid = uid;
			_type = type.toLowerCase();
			_status = ResourceLoadingStatus.ADDED_TO_LOADING_LIST;
			_method = method;
			_params = params;
		}
		
		public function set uid (uid_value:String) :void {
			_uid = uid_value;
		}
		
		public function get uid () :String {
			return _uid;
		}
		
		public function set name (name_value:String) :void {
			_name = name_value;
		}
		
		public function get name () :String {
			return _name;
		}
		
		public function set type (type_value:String) :void {
			_type = type_value.toLowerCase();
		}
		
		public function get type () :String {
			return _type;
		}
				
		public function set status (value:String) :void {
				_status = value;
		}
		
		public function get status () :String {
			return _status;
		}
		
		public function toString () :String {
			var debugMessage:String;
			debugMessage = 'Resource {uid: "' + uid + '", name: "' + name + '", type: ' + type + ', status: '+ _status+'}';
			return debugMessage;
		}
		
		public function set source (by:*) :void 
		{
			_source = by;
		}
				
		public function get source () :* {
			return _source;
		}
		
		public function set method (value:String) :void {
			_method = value;
		}
		
		public function get method () :String {
			return _method;
		}
		
		public function get params () :Object {
			return _params;
		}
		
		public function set params (value:Object) :void {
			_params = value;
		}
		
	}

}