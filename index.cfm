<!--- We need to include the plugin config to get access to the Mura scope --->
<cfinclude template="plugin/config.cfm" />

<!--- We need to import CFUniform Lib to create awesome forms --->
<cfimport taglib="/cfuniform/tags/forms/cfUniForm" prefix="uform" />

<!--- Javascript for updating and deleting subjects --->
<cfsavecontent variable="js">
	<cfoutput>
	<script type="text/javascript">
		
		jQuery(document).ready(function($){
			$('.deleteButton').bind('click', function(e){
				e.preventDefault();
				
				var confirm = confirmDialog('Delete Subject?', function(){
					$.ajax({
						type: 'POST',
						url: '#XMLFormat(cgi.SCRIPT_NAME)#',
						data: {
							subjectid: e.target.id.split("_")[1],
							doaction: 'deleteSubject'
						},
						success: function(data, textStatus){
							document.location = '#XMLFormat(cgi.SCRIPT_NAME)#'
						}
					});
				});
			})

			$('.editButton').bind('click', function(e){
				e.preventDefault();
				
				var id = e.target.id.split("_")[1];
				
				$('##subjectid').val(id);
				$('##subject').val($('##table_' + id).children()[0].innerHTML);
				$('##sendTo').val($('##table_' + id).children()[1].innerHTML);
				$('.primaryAction').html("Edit Contact Subject");
			})
			
			$('.resetButton').bind('click', function(e){
				e.preventDefault();
				
				$('##subjectid').val(0);
				$('##subject').val("");
				$('##sendTo').val("");
				$('.errorField').removeClass('errorField');
				
				$('.primaryAction').html("Add Contact Subject");
			});
		});
		
	</script>
	</cfoutput>
</cfsavecontent>

<!--- Get the plugin's application scope --->
<cfset pApp = pluginConfig.getApplication() />

<cfset subjGateway = pApp.getValue("subjectGateway") />
<cfset subjects = subjGateway.getAllSubjects() />

<cfhtmlhead text="#js#" />

<!--- Set form variables --->
<cfset successMsg = "" />
<cfset err = [] />

<!--- Check to see if the form was submitted --->
<cfif $.event('doaction') eq "saveSubject">
	<!--- Error Checking --->
	<cfif NOT len($.event('subject'))>
		<cfset arrayAppend( err , { field = 'subject', message = "You must enter a subject" } ) />
	</cfif>
	
	<!--- Check to see if sendTo is empty --->
	<cfif NOT len($.event('sendTo'))>
		<cfset arrayAppend( err , { field = 'sendTo', message = "You must enter at least one email" } ) />
	<cfelse>
		<!--- Make sure that sendTo only has valid emails --->
		<cfloop list="#$.event('sendTo')#" index="listIndex">
			<cfif NOT isvalid("email", listIndex)>
				<cfset arrayAppend(err, {field="sendTo", message="The email #listIndex# is not a valid email address"}) />
			</cfif>
		</cfloop> 
	</cfif>
	
	<!--- If no errors, save subject --->
	<cfif NOT arrayLen(err)>
		<cfif $.event('subjectid') eq 0>
			<!--- Save a new subject --->
			<cfset saveErr = subjGateway.addSubject($.event('subject'), $.event('sendTo')) />
		<cfelse>
			<!--- Update an existing subject --->
			<cfset saveErr = subjGateway.updateSubject($.event('subjectid'), $.event('subject'), $.event('sendTo')) />
		</cfif>	
		
		<!--- If saving worked ok, clear event to clear form --->
		<cfif NOT len(saveErr)>
			<cfset successMsg = "Success" />
			<cfset subjects = subjGateway.getAllSubjects() />
			<cfset $.event('subject', '') />
			<cfset $.event('sendTo', '') />
			<cfset $.event('subjectid', '') />
		<cfelse>
			<cfset arrayAppend(err, {field="subject", message=saveErr}) />
		</cfif>
	</cfif>
</cfif>

<!--- If a delete request was sent --->
<cfif $.event('doaction') eq "deleteSubject">
	<cfset deleteError = subjGateway.deleteSubject($.event('subjectid')) />
	
	<cfif NOT len(deleteError)>
		<cfset successMsg = "Subject Deleted" />
		<cfset subjects = subjGateway.getAllSubjects() />
		<cfset $.event('subject', '') />
		<cfset $.event('sendTo', '') />
	<cfelse>
		<cfset arrayAppend(err, {field="subject", message=deleteError}) />
	</cfif>
</cfif>

<!--- Store the body of the page in a variable so it can be passed into renderAdminTemplate() below --->
<cfsavecontent variable="plugin_body">
	<cfoutput>
    	
		<h2>Contact Us Config</h2>
	
		<h3>Subjects</h3>
		<table>
			<tr>
				<th>Subject</th>
				<th>Send To</th>
				<th>Actions</th>
			</tr>
		
		<!--- Display a table of all of the subjects along with buttons for edit/delete --->
		<cfif arraylen(subjects)>
			<cfloop array="#subjects#" index="subjIndex">
				<tr id="table_#subjIndex.getID()#">
					<td style="text-align:left" class="subject">#subjIndex.getSubject()#</td>
					<td style="text-align:left" class="sendTo">#subjIndex.getSendTo()#</td>
					<td>
						<a href="" class="editButton" id="edit_#subjIndex.getID()#">Edit</a>&nbsp;&nbsp;&nbsp;
						<a href="" class="deleteButton" id="delete_#subjIndex.getID()#">Delete</a>
					</td>
				</tr>
				
			</cfloop>
		<cfelse>
			<li>There are currently no contact subjects</li>
		</cfif>
		</table>
		<br /><br />
		
		<!--- Display add/edit subject form using CFUniform --->
		<h3>Add Subjects</h3>
		<uform:form action="#xmlFormat(cgi.SCRIPT_NAME)#?#cgi.QUERY_STRING#" 
		     id="addSubjectForm" 
		     errorMessagePlacement="inline" 
		     okMsg="#successMsg#" 
			 errors='#err#'
		     submitValue=" Add Contact Subject " 
		     loadValidation="true"
			 showReset="true">
		     	
			<input type="hidden" name="doaction" id="doaction" value="saveSubject" />
			<input type="hidden" name="subjectid" id="subjectid" value="#iif($.event('subjectid') eq '', 0, de($.event('subjectid')))#" />
			
			<uform:fieldset legend="Required Fields">
			 	<uform:field label="Subject" 
			       name="subject" 
			       isRequired="true" 
			       type="text"
				   hint="This is the text that will show up in the <em>subject</em> dropdown on the <strong>Contact Us</strong> form" 
			       value="#$.event('subject')#" />
				
				<uform:field label="Send To" 
			       name="sendTo" 
			       isRequired="true" 
			       type="text"
				   maxFieldLength="500"
				   hint="A comma delimted list of e-mail address to send the contact info to" 
			       value="#$.event('sendTo')#" />	    
			</uform:fieldset>
		</uform:form>	
    </cfoutput>
</cfsavecontent>

<cfoutput>
	<!--- This will render the page inside of the mura admin template --->
	#$.getBean('pluginmanager').renderAdminTemplate(body=plugin_body,pageTitle=pluginConfig.getName())#
</cfoutput>



