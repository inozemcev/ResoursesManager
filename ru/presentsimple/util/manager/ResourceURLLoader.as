package ru.presentsimple.util.manager
{
	import flash.net.URLLoader;
	
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public class ResourceURLLoader extends URLLoader
	{
		private var _uid:String;
				
		public function get uid () :String {
			return _uid;
		}
		
		public function set uid (value:String) :void {
			_uid = value;
		}
		
	}

}