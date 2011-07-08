<cfcomponent extends="mura.cfobject" output="false">
	
	<cffunction name="onApplicationLoad">
		<cfargument name="$" hint="Mura Scope" />
		
		<!--- Get the plugin configuration info, we need it to get the dbTablePrefix and the plugins application scope--->
		<cfset variables.pluginConfig = $.getBean('pluginManager').getConfig('ContactUsPluginDCTC') />
		
		<!--- get the plugins application scope --->
		<cfset pApp = variables.pluginConfig.getApplication() />

		<!--- put the subjectGateway into the plugin's app scope (singleton) --->
		<cfset pApp.setValue("subjectGateway", createObject("component","ContactUsPluginDCTC.model.SubjectGateway").init(application.configBean.getDataSource(), variables.pluginConfig.getSetting("dbTablePrefix"))) />


		<!--- Register event handlers --->
		<cfset variables.pluginConfig.addEventHandler(this) />
	</cffunction>
	
</cfcomponent>