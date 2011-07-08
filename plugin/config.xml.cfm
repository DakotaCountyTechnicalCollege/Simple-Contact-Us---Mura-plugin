<plugin>
	<name>Contact Us</name>
	<package>ContactUsPluginDCTC</package>
	<directoryFormat>packageOnly</directoryFormat>
	<version>0.1</version>
	<loadPriortiy>10</loadPriortiy>
	<provider>Dakota County Technical College</provider>
	<providerURL>http://www.dctc.edu</providerURL>
	<category>Application</category>
	<settings>
		<setting>
			<name>dbTablePrefix</name>
			<label>DB table Prefix</label>
			<hint>This plugin creates a few database tables. If you are worried about conflict, use this field to place a unique prefix on the table names (Include an underscore if you want one)</hint>
			<type>text</type>
			<required>false</required>
			<validation>regex</validation>
			<regex>[A-Za-z0-9_]*</regex>
			<message>Table prefix can be alphanumeric with underscores only</message>
			<defaultValue></defaultValue>
			<optionlist></optionlist>
			<optionlabellist></optionlabellist>
		</setting>
	</settings>
		
	<eventHandlers>
		<eventHandler event="onApplicationLoad" component="contactUsEventHandlers.contactUsHandler" persist="true" />
	</eventHandlers>
	
	<displayObjects location="global">
		<displayObject name="contactUsForm" displayMethod="showForm" component="displayObjects/contactUsForm.cfm" persist="false" />
	</displayObjects>
	
</plugin>