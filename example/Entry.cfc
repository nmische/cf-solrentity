component persistent="true" table="entry" extends="SolrEntity" solrcollection="blog" {

	property name="entryid" filedtype="id" generator="native" solrfield="key";
	property name="author" fieldtype="many-to-one" fkcolumn="authorid" cfc="Author";
	property name="title" solrfield="title";
	property name="content" solrfield="body";
	
	function getAuthorName() solrfield="author" {
		return this.getAuthor().getName();
	}
	
	function setAuthor(author) {	
		if (!IsNull( arguments.author)) {				
			variables.author = arguments.author;						
			if (!arguments.author.hasEntry(this)) {	
				if (!IsNull(arguments.author.getEntries())){
					ArrayAppend( arguments.author.getEntries(), this );	
				} else {
					arguments.author.setEntries([this]);
				}											
			}		
		}	
	}

}
