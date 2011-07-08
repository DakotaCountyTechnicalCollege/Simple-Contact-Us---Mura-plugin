<!--- This file is used for things that need to happen at install, update, or removal of the plugin --->
<cfcomponent extends="mura.plugin.plugincfc" output="false">
	
	<cffunction name="install" returntype="void" access="public" output="false" hint="This method runs when the plugin is installed. ">
		<cfset super.install() />
		
		<!--- Create the needed DB table --->
		<!--- Not the use of the dbTablePrefix. This is a plugin setting that the user is asked for when the plugin 
			is installed incase they want to use a prefix to avoid conflicts. This prefix needs to be used in ALL queries for this table --->
		<cfquery name="createSubjectTable" datasource="#application.configBean.getDatasource()#">
			CREATE TABLE #pluginConfig.getSetting("dbTablePrefix")#contactsubjects (
				subjectid CHAR(35) NOT NULL PRIMARY KEY,
				subject VARCHAR(128),
				emails VARCHAR(4000)
			) <cfif application.configBean.getDBType() eq "mysql">ENGINE = INNODB</cfif>
		</cfquery>
		
	</cffunction>
	
	<cffunction name="delete" returntype="void" access="public" output="false">
		<cfset super.delete() />
		
		<!--- Delete the DB Table, the plugin is being rmeoved and we don't need it anymore --->
		<cfquery name="removeSubjectTable" datasource="#application.configBean.getDatasource()#">
			DROP TABLE #pluginConfig.getSetting("dbTablePrefix")#contactsubjects
		</cfquery>		
	</cffunction>
</cfcomponent>