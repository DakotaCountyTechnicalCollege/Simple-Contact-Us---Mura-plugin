<!--- Import the CFUniform Tag Lib --->
<cfimport taglib="/cfuniform/tags/forms/cfUniForm" prefix="uform" />

<!--- Initialize CFFormProtect for spam blocking --->
<cfset cffp = CreateObject("component","cfformprotect.cffpVerify").init() />

<!--- Get the plugin's application scope --->
<cfset pApp = pluginConfig.getApplication() />

<!--- Get the subject gateway out --->
<cfset subjGateway = pApp.getValue("subjectGateway") />

<!--- Get all of the contact us subjects --->
<cfset subjects = subjGateway.getAllSubjects() />

<!--- Init variables for erro and success --->
<cfset success = "" />
<cfset errors = [] />

<!--- By default I only want inline errors. In certain situations, I will change this to show inline and errors at the top (This is a feature of CFUniform) --->
<cfset showErrors = "inline" />

<!--- Check to see if the form was submitted --->
<cfif $.event('doaction') eq "sendMessage">

	<!--- Test the values submitted against CFFormProtect --->
	<cfif NOT cffp.testSubmission(FORM)>
		<cfset arrayAppend(errors,{ field="", message="Our spam protection has determined that this entry is invalid. If this is a mistake, please try again." }) />
		<cfset showErrors = "both" /> <!--- Since the above error is not associated with a specific field, I want it to show at the top --->
	</cfif>
	
	<!--- Error Checking --->
	<cfif NOT len($.event('name'))>
		<cfset arrayAppend(errors,{ field="name", message="You must enter your name" }) />
	</cfif>
	
	
	<cfif NOT isvalid("email", $.event('emailAddress')) >
		<cfset arrayAppend(errors,{ field="emailAddress", message="Invalid e-mail address" }) />
	</cfif>
	
	<cfif NOT len($.event('emailAddress'))>
		<cfset arrayAppend(errors,{ field="emailAddress", message="You must enter your e-mail address" }) />
	</cfif>
	
	<cfif $.event('subject') eq "">
		<cfset arrayAppend(errors,{ field="subject", message="You must select a subject" }) />
	</cfif>
	
	<cfif NOT len($.event('message'))>
		<cfset arrayAppend(errors,{ field="message", message="You must enter a message" }) />
	</cfif>
	
	<cfif NOT arrayLen(errors)>
		<!--- get the Mura Mailer --->
		<cfset mailer = application.serviceFactory.getBean('mailer') />
		
		<!--- get the Subject object --->
		<cfset subjectObj = subjGateway.getSubjectByID($.event('subject')) />

		<!--- Create the email body --->
		<cfsavecontent variable="body">
				<cfoutput>
					Subject: #subjectObj.getSubject()#<br />
					Email: #$.event('emailAddress')#<br />
					<cfif $.event('phoneNumber') neq "">
						Phone: #$.event('phoneNUmber')#<br />
					</cfif>
					Message: #$.event('message')# <br />
				</cfoutput>
		</cfsavecontent>
		
		<!--- We're goingto count how many emails were sent --->
		<cfset successcount = 0 />
		
		<cftry>
			<!--- Send message message to recipients --->
			<cfset mailer.sendHTML(
									from = $.event('name'), 
									replyto = $.event('emailAddress'), 
									sendto = subjectObj.getSendTo(), 
									subject = subjectObj.getSubject(),
									html = body,
									bcc = '',
									siteID = session.siteid
						) />
					
			<!--- ++ for successful send --->
			<cfset successcount =  successcount + 1 />
					
			<cfcatch>
				<!--- show an error if it fails --->
				<cfset arrayAppend(errors,{ field="", message="There was a problem sending the message. Error Code: 303" }) />
				<cfset showErrors = "both" />
			</cfcatch>
		</cftry>
		
		<!--- Only send to the original poster if the initial email went through and they checked the apporpriate box --->
		<cfif $.event('sendCopy') eq 1 AND successcount eq 1>
			<cftry>
				<!--- Send message message to OP --->
				<cfset mailer.sendHTML(
										from = $.event('name'), 
										replyto = $.event('emailAddress'), 
										sendto = $.event('emailAddress'), 
										subject = subjectObj.getSubject(),
										html = body,
										bcc = '',
										siteID = session.siteid
							) />

				<!--- This should increase the success count to 2 --->
				<cfset successcount =  successcount + 1 />
						
				<cfcatch>
					<!--- show an error if this failed --->
					<cfset arrayAppend(errors,{ field="message", message="There was a problem sending the message. Error Code: 404" }) />
				</cfcatch>
			</cftry>
		</cfif>
		
		<!--- If the success counts are good, display a success message (CFUniform) and clear the event values so that the form is cleared out --->
		<cfif (successcount eq 2) OR (successcount eq 1 AND $.event('sendCopy') neq 1)>
			<cfset success = "You message has been sent. Thank you." />
			<cfset $.event().removeValue('name') />
			<cfset $.event().removeValue('emailAddress') />
			<cfset $.event().removeValue('phoneNUmber') />
			<cfset $.event().removeValue('subject') />
			<cfset $.event().removeValue('message') />
			<cfset $.event().removeValue('sendCopy') />
		</cfif>
	</cfif>

</cfif>


<cfoutput>
<!--- BEGIN CFUniform --->
<uform:form action="./?#CGI.QUERY_STRING#" 
    id="contactForm" 
    errorMessagePlacement="#showErrors#" 
    okMsg="#success#" 
	errors="#errors#"
    submitValue=" Send " 
    loadjQuery="false" 
    loadValidation="true" 
	>
	
	<input type="hidden" name="doaction" value="sendMessage" />
	
	<!--- include for CFFormProtect --->
	<cfinclude template="/cfformprotect/cffp.cfm">

	<uform:fieldset legend="">
	 	<uform:field label="Name" 
	       name="name" 
	       isRequired="true" 
	       type="text" 
	       value="#$.event('name')#" />
		   
    	<uform:field label="Email Address" 
	       name="emailAddress" 
	       isRequired="true" 
	       type="text" 
	       value="#$.event('emailAddress')#" 
	       hint="Please enter an email address so we can contact you" />
    
		<uform:field label="Phone Number" 
	       name="phoneNumber" 
	       isRequired="false" 
	       type="text" 
	       value="#$.event('phoneNumber')#" 
	       hint="Note: If you would prefer we call you" />
    
		<uform:field type="select" isRequired="true" name="subject">
				<option value="">Choose a subject</option>
				<cfloop array="#subjects#" index="subjIndex">
					<cfoutput><option value="#subjIndex.getID()#"<cfif $.event('subject') eq subjIndex.getID()>selected="selected"</cfif>>#subjIndex.getSubject()#</option></cfoutput>
				</cfloop>
		</uform:field>
		
		<uform:field type="checkbox" 
			label="Send me a copy of this email" 
			name="sendCopy"
			value="1" 
			isChecked="#$.event('sendCopy') eq 1#" />
		
		<uform:field label="Message" 
			name="message" 
			
			isRequired="true" 
			type="textarea" 
			value="#$.event('message')#"  />
		
	</uform:fieldset>
</uform:form>

</cfoutput>