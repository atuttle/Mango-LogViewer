<!---
LICENSE INFORMATION:

Copyright 2008, Adam Tuttle
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not 
use this file except in compliance with the License. 

You may obtain a copy of the License at 

	http://www.apache.org/licenses/LICENSE-2.0 
	
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
CONDITIONS OF ANY KIND, either express or implied. See the License for the 
specific language governing permissions and limitations under the License.

VERSION INFORMATION:

This file is part of LogViewer Beta 1 (0.3).
--->
<cfcomponent displayname="Handler">
	<cfset variables.name = "LogViewer" />
	<cfset variables.id = "com.tuttle.plugins.LogViewer" />
	<cfset variables.package = "com/tuttle/plugins/LogViewer"/>

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />

		<cfset variables.mainManager = arguments.mainManager />
		<cfset variables.preferences = arguments.preferences />
		
		<cfset variables.pluginPath = arguments.mainManager.getBlog().getId() & "/" & variables.package />
		
		<cfset variables.basePath = arguments.mainManager.getBlog().getBasePath() />
		<cfset variables.warningPath = variables.basePath & "components/utilities/logs/warning.log.html"/>
		<cfset variables.errorPath = variables.basePath & "components/utilities/logs/error.log.html"/>
		
		<cfreturn this/>
	</cffunction>
	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn variables.name />
	</cffunction>
	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="name" type="string" required="true" />
		<cfset variables.name = arguments.name />
		<cfreturn />
	</cffunction>
	<cffunction name="getId" access="public" output="false" returntype="any">
		<cfreturn variables.id />
	</cffunction>
	<cffunction name="setId" access="public" output="false" returntype="void">
		<cfargument name="id" type="any" required="true" />
		<cfset variables.id = arguments.id />
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="setup" hint="This is run when a plugin is activated" access="public" output="false" returntype="any">
		<cfreturn "Plugin activated" />
	</cffunction>
	<cffunction name="unsetup" hint="This is run when a plugin is de-activated" access="public" output="false" returntype="any">
		<cfreturn "Plugin De-activated" />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="handleEvent" hint="Asynchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />
		<!--- doesn't respond to any asynch events --->
		<cfreturn />
	</cffunction>

<!--- :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: --->	
	<cffunction name="processEvent" hint="Synchronous event handling" access="public" output="false" returntype="any">
		<cfargument name="event" type="any" required="true" />

		<cfset var i = 0 />
		<cfset var link = "" />
		<cfset var page = "" />
		<cfset var data = ""/>
		
		<cfif arguments.event.getName() EQ "mainNav">
			<cfset link = structnew() />
			<cfset link.owner = "LogViewer">
			<cfset link.page = "generic" />
			<cfset link.title = "Log Viewer" />
			<cfset link.eventName = "logViewer-dash" />
			
			<cfif logsExist()>
				<cfset link.title = "<strong>Log Viewer</strong>"/>
			</cfif>
			
			<cfset arguments.event.addLink(link)>

		<cfelseif arguments.event.getName() EQ "logViewer-dash">
			<cfset data = arguments.event.getData() />
			
			<cfif structKeyExists(arguments.event.data.externalData,"clear")>
				<cfset clearLogs()/>
			</cfif>

			<cfsavecontent variable="page">
				<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.0/jquery.min.js"></script>
				<style>
					table.cfdump_struct th.struct {background:#44C !important;}
					table.cfdump_array th.array {background:#090 !important;}
				</style>
				<ul>
					<cfif warningsExist()>
						<li><a href="javascript:void(0);" id="lv_err">Warning Log</a></li>
						<script type="text/javascript">
							jQuery(document).ready(function($){
								$("#lv_err").click(function(){
									$("#log").load('<cfoutput>#variables.warningPath#?refresh=#dateFormat(now(),'YYYYMMDD')##timeFormat(now(),'HHMMSS')#</cfoutput>');
								});
							});
						</script>
					</cfif>
					<cfif errorsExist()>
						<li><a href="javascript:void(0);" id="lv_warn">Error Log</a></li>
						<script type="text/javascript">
							jQuery(document).ready(function($){
								$("#lv_warn").click(function(){
									$("#log").load('<cfoutput>#variables.errorPath#?refresh=#dateFormat(now(),'YYYYMMDD')##timeFormat(now(),'HHMMSS')#</cfoutput>');
								});
							});
						</script>
					</cfif>
					<cfif not logsExist()>
						<li>No errors or warnings. Woohoo!</li>
					<cfelse>
						<li><a href="generic.cfm?event=logViewer-dash&owner=LogViewer&selected=logViewer-dash&clear=true" style="color:red;">Clear logs</a></li>
					</cfif>
				</ul>
				<br/>
				<div id="log" style="background:##eee;"></div>
			</cfsavecontent>

			<!--- change message --->
			<cfset data.message.setTitle("Log Viewer") />
			<cfset data.message.setData(page) />
		</cfif>

		<cfreturn arguments.event />
	</cffunction>

	<cffunction name="logsExist" access="private" output="false" returntype="boolean">
		<cfreturn (warningsExist() or errorsExist()) />
	</cffunction>
	<cffunction name="warningsExist" access="private" output="false" returnType="boolean">
		<cfreturn fileExists(expandPath(variables.warningPath))/>
	</cffunction>
	<cffunction name="errorsExist" access="private" output="false" returnType="boolean">
		<cfset var logPath = variables.basePath & "components/utilities/logs/error.log.html"/>
		<cfreturn fileExists(expandPath(variables.errorPath))/>
	</cffunction>
	<cffunction name="clearLogs" access="private" output="false" returnType="void">
		<cfif warningsExist()>
			<cffile action="delete" file="#expandPath(variables.warningPath)#"/>
		</cfif>
		<cfif errorsExist()>
			<cffile action="delete" file="#expandPath(variables.errorPath)#"/>
		</cfif>
	</cffunction>

</cfcomponent>