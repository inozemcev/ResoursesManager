package ru.presentsimple.util.manager 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author sergey kostin (embria)
	 */
	public interface IResource
	{
		function get uid () :String;
		function set uid (value:String) :void;
		function set name (value:String) :void;
		function get name () :String;
		function set type (value:String) :void;
		function get type () :String;
		
		function set method (value:String) :void;
		function get method () :String;
		
		function set params (value:Object) :void;
		function get params () :Object;
		
		function get status () :String;
		function set status (value:String) :void; 
		
		function get source () :*;
		function set source (value:*) :void;
	}

}