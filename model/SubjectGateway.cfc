<cfcomponent>
	
	<cfset variables.dsn = "" />
	<cfset variables.prefix = "" />
	
	<cffunction name="init" access="public" returntype="ContactUsPluginDCTC.model.SubjectGateway" output="false">
		<cfargument name="dsn" type="string" />
		<cfargument name="tablePrefix" />
		
		<cfset variables.dsn = arguments.dsn />
		<cfset variables.prefix = arguments.tablePrefix />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getAllSubjects" access="public" returntype="Array" output="false">
		<!--- This method will return all of the subjects in the DB as an array of Subject objects --->
		<cfset var returnArray = ArrayNew(1) />
		<cfset var currentSubject = "" />
		<cfset var getSubjects = "" />
		
		<cfquery name="getSubjects" datasource="#variables.dsn#">
			SELECT subjectid, subject, emails
			FROM #variables.prefix#contactsubjects
		</cfquery>
		
		<cfloop query="getSubjects">
			<cfset currentSubject = createObject("component","ContactUsPluginDCTC.model.Subject").init(getSubjects.subjectid, getSubjects.subject, getSubjects.emails) />
			<cfset arrayAppend(returnArray, currentSubject) />
		</cfloop>
		
		<cfreturn returnArray />
	</cffunction>
	
	<cffunction name="addSubject" access="public" returntype="String" output="false" hint="Returns a string to be used as an error message">
		<cfargument name="subject" type="String" required="true" />
		<cfargument name="sendTo" type="String" required="true" />
		
		<cfset var qCheck = "" />
		<cfset var error = "" />
		
		<cftry>
			<!--- check to see if the subject already exists --->
			<cfquery name="qCheck" datasource="#variables.dsn#">
				SELECT subjectid
				FROM #variables.prefix#contactsubjects
				WHERE subject = <cfqueryparam value="#arguments.subject#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			
			<cfif qCheck.RecordCount GT 0>
				<!--- Return error message --->
				<cfreturn "Subject already exists" />
			</cfif>
			
			<cfquery name="insertSubject" datasource="#variables.dsn#">
				INSERT INTO #variables.prefix#contactsubjects (
					subjectid,
					subject,
					emails
				) VALUES (
					<cfqueryparam value="#createUUID()#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#trim(arguments.subject)#" cfsqltype="cf_sql_varchar" />,
					<cfqueryparam value="#replace(trim(arguments.sendTo), " ", "")#" cfsqltype="cf_sql_varchar" />
				)
			</cfquery>
			
			<cfcatch>
				<!--- If something fails, return the error message --->
				<cfset error = cfcatch.message />
			</cfcatch>
		</cftry>
		<cfreturn error />
		
	</cffunction>
	
	<cffunction name="getSubjectbyID" access="public" returntype="ContactUsPluginDCTC.model.Subject" output="false">
		<cfargument name="subjectid" />
		
		<cfset var getSubject = "" />
		<cfset var currentSubject = "" />
		
		<cfquery name="getSubject" datasource="#variables.dsn#">
			SELECT subjectid, subject, emails
			FROM #variables.prefix#contactsubjects
			WHERE subjectid = <cfqueryparam value="#arguments.subjectid#" cfsqltype="cf_sql_varchar" />
		</cfquery>
		
		<cfloop query="getSubject">
			<cfset currentSubject = createObject("component","ContactUsPluginDCTC.model.Subject").init(getSubject.subjectid, getSubject.subject, getSubject.emails) />
		</cfloop>
		
		<cfreturn currentSubject />
	</cffunction>
	
	<cffunction name="updateSubject" access="public" returntype="String" output="false" hint="Returns a string to be used as an error message">
		<cfargument name="subjectid" type="String" required="true" />
		<cfargument name="subject" type="String" required="true" />
		<cfargument name="sendTo" type="String" required="true" />
		
		<cfset var qCheck = "" />
		<cfset var error = "" />
		
		<cftry>
			<!--- Check to see if the subject exists, other than the one we're actually editing --->
			<cfquery name="qCheck" datasource="#variables.dsn#">
				SELECT subjectid
				FROM #variables.prefix#contactsubjects
				WHERE subject = <cfqueryparam value="#arguments.subject#" cfsqltype="cf_sql_varchar" />
					AND subjectid <> <cfqueryparam value="#arguments.subjectid#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			
			<cfif qCheck.RecordCount GT 0>
				<cfreturn "Subject already exists" />
			</cfif>
			
			<cfquery name="updateSubject" datasource="#variables.dsn#">
				UPDATE #variables.prefix#contactsubjects 
				SET subject = <cfqueryparam value="#trim(arguments.subject)#" cfsqltype="cf_sql_varchar" />,
					emails = <cfqueryparam value="#replace(trim(arguments.sendTo), " ", "")#" cfsqltype="cf_sql_varchar" />
				WHERE subjectid = <cfqueryparam value="#arguments.subjectid#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			
			<cfcatch>
				<cfset error = cfcatch.message />
			</cfcatch>
		</cftry>
		<cfreturn error />
		
	</cffunction>



	<cffunction name="deleteSubject" access="public" returntype="String" output="false" hint="Returns a string to be used as an error message">
		<cfargument name="subjectid" type="string" />
		
		<cfset var deleteSubject = "" />
		
		<cftry>
			<cfquery name="deleteSubject" datasource="#variables.dsn#">
				DELETE FROM #variables.prefix#contactsubjects
				WHERE subjectid = <cfqueryparam value="#arguments.subjectid#" cfsqltype="cf_sql_varchar" />
			</cfquery>
			
			<cfcatch>
				<cfreturn "There was a problem deleting the subject, please try again later" />
			</cfcatch>	
		</cftry>
		
		<cfreturn "" />
	</cffunction>
</cfcomponent>