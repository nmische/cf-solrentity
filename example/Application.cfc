component {

	this.name = "SampleSolrEntityApp";
	this.ormEnabled = true;
	this.datasource = "solr";
	this.ormSettings = { eventhandling = true };
	
	function onRequestStart() {	
		if (StructKeyExists(url,"reload_orm")){
			ormReload();		
		}	
	}

}
