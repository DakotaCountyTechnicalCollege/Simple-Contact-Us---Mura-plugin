<cfcomponent>
	
	<cfset variables.id = "" />
	<cfset variables.subject = "" />
	<cfset variables.sendTo = "" />
	
	<cffunction name="init" access="public" returntype="ContactUsPluginDCTC.model.Subject" output="false">
		<cfargument name="id" type="String" required="false" />
		<cfargument name="subject" type="string" required="false" />		
		<cfargument name="sendTo" type="String" required="false" />
		
		<cfset setID(arguments.id) />
		<cfset setSubject(arguments.subject) />
		<cfset setSendTo(arguments.sendTo) />
		
		<cfreturn this />
	</cffunction>

	<cffunction name="getID" access="public" returntype="String" output="false">
		<cfreturn variables.id />
	</cffunction>
	
	<cffunction name="getSubject" access="public" returntype="String" output="false">
		<cfreturn variables.subject />
	</cffunction>
	
	<cffunction name="getSendTo" access="public" returntype="String" output="false">
		<cfreturn variables.sendTo />
	</cffunction>
	
	<cffunction name="setID" access="public" returntype="void" output="false">
		<cfargument name="id" type="string" required="true" />
		
		<cfset variables.id = arguments.id />
	</cffunction>
	
	<cffunction name="setSubject" access="public" returntype="void" output="false">
		<cfargument name="subject" type="string" required="true" />
		
		<cfset variables.subject = arguments.subject />
	</cffunction>
	
	<cffunction name="setSendTo" access="public" returntype="void" output="false">
		<cfargument name="sendTo" type="string" required="true" />
		
		<cfset variables.sendTo = arguments.sendTo />
	</cffunction>
</cfcomponent>