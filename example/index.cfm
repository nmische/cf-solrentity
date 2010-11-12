<cfsilent>

<cfparam name="url.action" default="search" />
<cfparam name="form.q" default="*:*" />

<!--- do stuff --->
<cfswitch expression="#url.action#">
		
	<cfcase value="search">
		<cfsearch collection="test" criteria="#form.q#" name="searchResults" />
	</cfcase>
	
	<cfcase value="addAuthor">
		<cfscript>
			author = EntityNew("Author");
			author.setName(form.name);
			EntitySave(author);
		</cfscript>
		<cflocation url="?action=search" />
	</cfcase>
	
	<cfcase value="addEntryForm">
		<cfscript>
			authors = EntityLoad("Author");
			qAuthors = EntityToQuery(authors);
		</cfscript>
	</cfcase>	
	
	<cfcase value="addEntry">
		<cfscript>
			author = EntityLoad("Author",form.authorid,true);
			entry = EntityNew("Entry");			
			entry.setAuthor(author);			
			entry.setTitle(form.title);
			entry.setContent(form.content);			
			EntitySave(entry);
		</cfscript>
		<cflocation url="?action=search" />
	</cfcase>
	
	<cfcase value="delete">
		<cfscript>
			entry = EntityLoad("Entry",url.entryid,true);
			EntityDelete(entry);
		</cfscript>
		<cflocation url="?action=search" />
	</cfcase>	
		
</cfswitch>

</cfsilent>

<!--- show stuff --->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
 "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
   <title>Solr Entity Test App</title>
   <link rel="stylesheet" href="http://yui.yahooapis.com/2.8.2r1/build/reset-fonts-grids/reset-fonts-grids.css" type="text/css">
   <link rel="stylesheet" type="text/css" href="http://yui.yahooapis.com/2.8.2r1/build/base/base-min.css">
   <style>
     #hd, #bd {background-color: #eee}
	 #hd, #nav {padding: 5px}
	 #content {background-color: #fff; padding: 5px}
   </style>
</head>
<body>
<div id="doc" class="yui-t2">
   <div id="hd">
   		<h1>Solr Entity Test App</h1>
   </div>
   <div id="bd">
	<div id="yui-main">
	  <div class="yui-b">
	    <div id="content" class="yui-g">
		
		<cfswitch expression="#url.action#">
		
			<cfcase value="search">
				<h3>Search Results</h3>
			
				<table>
					<tr>
						<th>Author</th>
						<th>Title</th>
						<th>Summary</th>
						<th></th>					
					</tr>
				    <cfoutput query="searchResults">
					<tr>
						<td>#author#</td>
						<td>#title#</td>
						<td>#summary#</td>
						<td><a href="?action=delete&entryid=#key#">Delete</a></td>					
					</tr>
				    </cfoutput>				
				</table>				
			</cfcase>
			
			<cfcase value="addAuthorForm">				
				<h3>Add Author</h3>
				
				<cfform action="?action=addAuthor" method="post">				
					<p>Name:<br/><cfinput type="text" name="name" size="40" maxlength="255"/></p>				
					<p><cfinput type="submit" name="submit" value="Submit"/></p>
				</cfform>				
			</cfcase>	
			
			<cfcase value="addEntryForm">				
				<h3>Add Entry</h3>
				
				<cfform action="?action=addEntry" method="post">	
					<p>Author:<br/><cfselect query="qAuthors" display="name" value="authorid" name="authorid" /></p>			
					<p>Title:<br/><cfinput type="text" name="title" size="40" maxlength="255" required="true"/></p>
					<p>Content:<br/><cftextarea name="content" rows="10" cols="40" maxlength="1000" required="true"></cftextarea></p>					
					<p><cfinput type="submit" name="submit" value="Submit"/></p>
				</cfform>				
			</cfcase>
		
		</cfswitch>
        </div>
      </div>
    </div>
    <div id="nav" class="yui-b">	
	
		<h3>Search:</h3>
	
		<form action="?action=search" method="post">
			<input type="text" name="q" />
			<input type="submit" name="submit" value="search" />
		</form>	
		
		<hr>
		
		<h3>Actions:</h3>
			
		<a href="?action=addEntryForm">Add Entry</a><br/>
		<a href="?action=addAuthorForm">Add Author</a><br/>
		
    </div>	
  </div>
  <div id="ft">
    <hr/>
    <p>Solr Entity Test App</p>
  </div>
</div>
</body>
</html>
