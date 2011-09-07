package ru.presentsimple.util.manager 
{
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	
	 
	public class ResourcesManager
	{
		private static var namesCash:Object;
			
		public static function get list () :ResourcesManagerList {
			return ResourcesManagerList.getInstance();
		}
		
		public static function get loader () :ResourcesManagerLoader {
			return ResourcesManagerLoader.getInstance ();
		}
		
		public static function get cache () :ResourcesManagerCache {
			return ResourcesManagerCache.getInstance();
		}
		
		public static function get uniqueName () :String {
			
			if (namesCash == null) {
				namesCash = new Object ();
			}
			
			var random:uint = Math.round (Math.random () * 0xFFFFFF);
			
			if (namesCash[random] == null) {
				namesCash[random] = random;
				return 'instance ' + random;
			} else {
				return ResourcesManager.uniqueName;
			}
		}
	}

}