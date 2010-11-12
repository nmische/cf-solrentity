component persistent="true" table="author" {

	property name="authorid" fieldtype="id" generator="native";
	property name="name";
	property name="entries" type="array" inverse="true" fieldtype="one-to-many" cfc="Entry" fkcolumn="authorid" lazy="true" singularname="Entry";

	function addEntry(entry) {
		entry.setAuthor(this);
	}

}