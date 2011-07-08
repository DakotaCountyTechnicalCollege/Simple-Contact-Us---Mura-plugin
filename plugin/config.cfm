<!--- This is the config file that allows the admin side of the plugin to integrate with Mura. The admin side is an application of it's own, so we need to do this stuff to give the plugin access to the mura scope for theming, access to things like Datasources, etc. --->
<cfsilent>
	<!--- Check to see if the murascope is already defined, if it is, then np, if not, then create it and add the FORM and URL scopes to it. --->
	<cfif not isDefined("$")>
		<cfset initArgs = StructNew() />
		<cfset StructAppend(initArgs, URL) />
		<cfset StructAppend(initArgs, FORM) />
		<cfset initArgs.siteID = session.siteID />

		<cfset $ = application.serviceFactory.getBean('muraScope').init(initArgs) />
	</cfif>

	<!--- Check to see if the plugin config is available, if not, then get it. --->
	<cfif not isDefined("pluginConfig")>
		<cfset pluginConfig = $.getBean('pluginManager').getConfig('ContactUsPluginDCTC') />
		
		<!--- If the plugin config is not available, then it means we are on the admin-side of the plugin, so we will set the plugin mode to admin so that we can block access to it. --->
		<cfset pluginConfig.setSetting("pluginMode","Admin")/>
	</cfif>

	<!--- This plugin is onyl available to the S2 Role --->
	<cfif pluginConfig.getSetting("pluginMode") eq "Admin" and not isUserInRole('S2')>
		<cfif not structKeyExists(session,"siteID") or not application.permUtility.getModulePerm(pluginConfig.getValue('moduleID'),session.siteid)>
			<cflocation url="#application.configBean.getContext()#/admin/" addtoken="false">
		</cfif>
	</cfif>

</cfsilent>