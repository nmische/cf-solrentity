component {

	variables.solrConfig = {};
		
	function postInsert() output="true" {
	
		var md = GetMetadata(this);	
	
		if (StructCount(variables.solrConfig) eq 0) {
			setSolrConfig(md);
		}
	
		doSolrUpdate(md);	
	
	}
	
	function postUpdate() output="true" {
	
		var md = GetMetadata(this);	
	
		if (StructCount(variables.solrConfig) eq 0) {
			setSolrConfig(md);
		}
	
		doSolrUpdate(md);
	
	}
	
	function postDelete() output="true" {
	
		var md = GetMetadata(this);	
	
		if (StructCount(variables.solrConfig) eq 0) {
			setSolrConfig(md);
		}
	
		doSolrDelete(md);
	
	}


	private function setSolrConfig(md) {				
		variables.solrConfig = {
			host = (StructKeyExists(md,"solrhost")) ? md.solrhost : "localhost",
			port = (StructKeyExists(md,"solrport")) ? md.solrport : "8983",
			path = (StructKeyExists(md,"solrpath")) ? md.solrpath : "/solr",		
			collection = (StructKeyExists(md,"solrcollection")) ? md.solrcollection : "core0",
			language = (StructKeyExists(md,"solrlanguage")) ? md.solrlanguage : "en"
		};	
	}
	
	private function doSolrUpdate(md) {
				
		var defaultFields = {
			url = "/",
			mime = "Entity",
			size = "",
			title = "",
			custom1 = "",
			custom2 = "",
			custom3 = "",
			custom4 = "",
			author = "",
			summary = "",
			modified = Int(getTickCount()/1000)		
		};
		var processedFields = {};
		var body = "";
		
		var addDoc = XmlNew(true);
		var addDoc.xmlRoot = XmlElemNew(addDoc,"add");
		
		ArrayAppend(addDoc.xmlRoot.xmlChildren,XmlElemNew(addDoc,"doc"));		
		
		// loop over properties		
		for (var i = 1; i lte ArrayLen(md.properties); i++) {
			if (StructKeyExists(md.properties[i],"solrfield")){
				var fieldName = md.properties[i].solrfield;
				fieldName = (fieldName eq "body") ? "contents_#variables.solrConfig.language#" : fieldName;
				var getter = this["get" & md.properties[i].name];					
				var el = XmlElemNew(addDoc,"field");
				StructInsert(el.xmlAttributes, "name", fieldName);
				el.xmlText = getter();
				ArrayAppend(addDoc.xmlRoot.xmlChildren[1].xmlChildren,el);
				
				if (fieldName eq "contents_#variables.solrConfig.language#") {
					body = el.xmlText;
				}
				
				processedFields[fieldName] = 1;
				
				if (fieldName eq "key") {
					// put key in uid field
					var el = XmlElemNew(addDoc,"field");
					StructInsert(el.xmlAttributes, "name", "uid");
					el.xmlText = md.name & "_" & getter();	
					ArrayAppend(addDoc.xmlRoot.xmlChildren[1].xmlChildren,el);
					processedFields["key"] = 1;
				}
			}		
		}		
				
		// loop over functions		
		for (var i = 1; i lte ArrayLen(md.functions); i++) {
			if (StructKeyExists(md.functions[i],"solrfield")){			
				if (ArrayLen(md.functions[i].parameters) gt 0) {
					throw "Solr entity functions that map to solr fields must take no arguments. The #md.functions[i].name# function is mapped to the #md.functions[i].solrfield# field but takes #ArrayLen(md.functions[i].parameters)# parameter(s).";
				}
				var fieldName = md.functions[i].solrfield;
				fieldName = (fieldName eq "body") ? "contents_#variables.solrConfig.language#" : fieldName;
				var func = this[md.functions[i].name];					
				var el = XmlElemNew(addDoc,"field");
				StructInsert(el.xmlAttributes, "name", fieldName);
				el.xmlText = func();				
				ArrayAppend(addDoc.xmlRoot.xmlChildren[1].xmlChildren,el);
				
				if (fieldName eq "contents_#variables.solrConfig.language#") {
					body = el.xmlText;
				}
				
				processedFields[fieldName] = 1;
				
				if (fieldName eq "key") {
					// put key in uid field
					var el = XmlElemNew(addDoc,"field");
					StructInsert(el.xmlAttributes, "name", "uid");
					el.xmlText = md.name & "_" & func();	
					ArrayAppend(addDoc.xmlRoot.xmlChildren[1].xmlChildren,el);
					processedFields["key"] = 1;
				}
			}		
		}		
		
		if (not StructKeyExists(processedFields,"key")){
			throw "This solr entity does not map a property or function to the key solr field.";
		}
		
		if (not StructKeyExists(processedFields,"contents_#variables.solrConfig.language#")){
			throw "This solr entity does not map a property or function to the body solr field.";
		}
		
		if (not StructKeyExists(processedFields,"size")){
			defaultFields.size = Len(body);
		}
		
		if (not StructKeyExists(processedFields,"summary")){
			defaultFields.summary = Left(body, 250);
		}
		
				
		// make sure all required fields are present
		for (field in defaultFields) {
			if (not StructKeyExists(processedFields,field)){						
				var el = XmlElemNew(addDoc,"field");
				StructInsert(el.xmlAttributes, "name", LCase(field));			
				if (defaultFields[field] neq "") {
					el.xmlText = defaultFields[field];
				}
				ArrayAppend(addDoc.xmlRoot.xmlChildren[1].xmlChildren,el);
				processedFields[field] = 1;			
			}
		
		}
				
		makeSolrRequest(addDoc);
	}
	
	private function doSolrDelete(md) {
	
		var deleteDoc = XmlNew(true);
		var deleteDoc.xmlRoot = XmlElemNew(deleteDoc,"delete");
		
		for (var i = 1; i lte ArrayLen(md.properties); i++) {
			if (StructKeyExists(md.properties[i],"solrfield") and md.properties[i].solrfield eq "key"){
				var fieldName = md.properties[i].solrfield;
				var getter = this["get" & md.properties[i].name];					
				var el = XmlElemNew(deleteDoc,"id");
				el.xmlText = md.name & "_" & getter();			
				ArrayAppend(deleteDoc.xmlRoot.xmlChildren,el);				
			}		
		}	
		
		makeSolrRequest(deleteDoc);
	}
	
	private function makeSolrRequest(doc) {	
	 	var cfg = variables.solrConfig;	
		var url = "http://#cfg.host#:#cfg.port##cfg.path#/#cfg.collection#/update";
		var h = new http(url=url,method="post");
		h.addParam(type="xml",value="#doc#");
		h.addParam(type="url",name="commit",value="true");
		var req = h.send();
		var result = req.getPrefix();
		if (result.statusCode neq "200 OK") {
			throw "Error updating collection.";
		}	
		
	}

}
