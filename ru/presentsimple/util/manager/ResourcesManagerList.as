package ru.presentsimple.util.manager
{
	
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public class ResourcesManagerList 
	{
		private static var _instance:ResourcesManagerList = null;
		
		private var list:Array;
		private var nameCash:Object;
			
		// обязательный метод Singleton
		public static function getInstance():ResourcesManagerList
		{
			if ( _instance == null )
			{
				_instance = new ResourcesManagerList();
			}
			return _instance;
		}
		
		// Конструктор
		public function ResourcesManagerList() 
		{
			if (list == null) {
				list = new Array ();
			}
		}
		
		public function add (data:*) :void {
			
			if (nameCash == null) {
				nameCash = new Object ();
			}
			
			if (data is IResource) {
				addResource (data);
			} else if (data is Array) {
				for (var instance:int; instance < data.length; instance ++) {
					addResource(data[instance]);
				}
			} else {
				throw new Error ('Error in ResourcesManagerList::add incorrect type of data');
			}
			
			function addResource (data:*) :void {
				
				if (lookResourceInNameCash (data)) 
				{
					// todo сделать возможным автоматическое исправление ошибки, при условии что существует соответсвующая настройка
					throw new Error ('Resource name is dublicated. In ResourceManagerList::add');
					return;
				} 
				
				list.push (data);
				nameCash[data.name] = data.name;
				
			}
		}
		
		internal function getLoadings (... args) :Array {
			
			if (args.length) 
			{
				var defineArr:Array = new Array ();
				
				for (var i:uint = 0; i < args.length; i++) 
				{ 
					var statusArr:Array = getStatusLoadings(args[i]);
					
					if (statusArr.length) {
						defineArr = defineArr.concat(statusArr);
					}
					
				} 
				
				return defineArr;
			}
			else
			{
				return getStatusLoadings(ResourceLoadingStatus.ADDED_TO_LOADING_LIST);
			}
		}
		
		private function getStatusLoadings (status:String) :Array {
			var defineArr:Array = new Array ();
			if (list == null)
			{
				throw Error ('ResoursesManager.list not yet initialized');
			}
			
			for (var instance:int = 0; instance < list.length; instance ++) 
			{
				var resource:IResource = list[instance] as IResource;
				
				if (resource.status == status) {
					defineArr.push (resource);
				}
			}
			
			return defineArr;
		}
		
		internal function getResourceByUID (uid:String) :IResource {
			for (var instance:int = 0; instance < list.length; instance ++ ) {
				if ((list[instance] as IResource).uid == uid) {
					return list[instance];
				}
			}
			
			return null;
		}
		
		public function get journal () :String {
			var str:String = ''
					
			str += 'ResourceManager.list JOURNAL. Total resources:' + list.length + '\n*\n';
			for (var instance:int = 0; instance < list.length; instance ++) 
			{
				str += list[instance].toString();
				if (instance != list[list.length -1]) 
				{
					str += ';'
					str += '\n*';
				}
			}
			return str;
		}
		
		private function lookResourceInNameCash (data:IResource) :Boolean {
			
			if (nameCash[data.name] != null) 
			{
				return true;
			}
						
			return false;
		}
		
		public function get length () :int
		{
			return list.length; 
		}
		
	}

}