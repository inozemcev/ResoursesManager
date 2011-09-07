package ru.presentsimple.util.manager
{
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public class ResourcesManagerCache 
	{
		private static var _instance:ResourcesManagerCache = null;
		
		private var cash:Object;
			
		// обязательный метод Singleton
		public static function getInstance():ResourcesManagerCache
		{
			if ( _instance == null )
			{
				_instance = new ResourcesManagerCache();
			}
			return _instance;
		}
		
		// Конструктор
		public function ResourcesManagerCache() 
		{
			cash = {};
		}
		
		public function getSource (uid:String) :* {
			if (cash[uid] != null) {
				return cash[uid];
			}
			
			return null;
		}
		
		public function getSourceByName (name:String) :* {
			if (cash[name] != null) {
				return cash[name];
			}
			return null;
		}
		
		public function addSource (uid:String, name:String, data:*) :void {
			if (cash[uid] != null) {
				if (cash[name] == null) cash[name] = cash[uid];
			}
			cash[uid] = cash[name] = data;
		}
	}

}