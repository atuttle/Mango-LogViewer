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

This file is part of LogViewer.
--->
<cfcomponent displayname="Handler" extends="BasePlugin">

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="mainManager" type="any" required="true" />
		<cfargument name="preferences" type="any" required="true" />

		<cfset setManager(arguments.mainManager) />
		<cfset setPreferencesManager(arguments.preferences) />
		<cfset setPackage("com/fusiongrokker/plugins/LogViewer") />

		<cfset variables.basePath = getManager().getBlog().getBasePath() />
		<cfset variables.warningPath = variables.basePath & "components/utilities/logs/warning.log.html"/>
		<cfset variables.errorPath = variables.basePath & "components/utilities/logs/error.log.html"/>

		<cfreturn this/>
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

		<cfset var link = "" />
		<cfset var page = "" />
		<cfset var data = ""/>
		<cfset var local = structNew() />

		<cfif arguments.event.getName() EQ "mainNav">
			<cfset link = structnew() />
			<cfset link.owner = "LogViewer">
			<cfset link.page = "generic" />
			<cfset link.title = "Log Viewer" />
			<cfset link.eventName = "logViewer-dash" />
			<cfset link.icon = "#getAdminAssetPath()#bug.png" />

			<cfif logsExist()>
				<cfset link.title = "<strong>Log Viewer</strong>"/>
				<cfset link.icon = "#getAdminAssetPath()#bug_error.png" />
			</cfif>

			<cfset arguments.event.addLink(link)>

		<cfelseif arguments.event.getName() EQ "logViewer-dash">
			<cfset data = arguments.event.getData() />

			<cfif structKeyExists(arguments.event.data.externalData,"clear")>
				<cfset clearLogs()/>
			</cfif>

			<cfsavecontent variable="page">
				<style>
					table.cfdump_wddx, table.cfdump_xml, table.cfdump_struct, table.cfdump_varundefined, table.cfdump_array, table.cfdump_query, table.cfdump_cfc, table.cfdump_object, table.cfdump_binary, table.cfdump_udf, table.cfdump_udfbody, table.cfdump_udfarguments {
						font-size: xx-small !important;
						font-family: verdana, arial, helvetica, sans-serif !important;
						cell-spacing: 2px !important;
					}
					table.cfdump_wddx th, table.cfdump_xml th, table.cfdump_struct th, table.cfdump_varundefined th, table.cfdump_array th, table.cfdump_query th, table.cfdump_cfc th, table.cfdump_object th, table.cfdump_binary th, table.cfdump_udf th, table.cfdump_udfbody th, table.cfdump_udfarguments th {
						text-align: left !important;
						color: white !important;
						padding: 5px !important;
					}
					table.cfdump_wddx td, table.cfdump_xml td, table.cfdump_struct td, table.cfdump_varundefined  td, table.cfdump_array td, table.cfdump_query td, table.cfdump_cfc td, table.cfdump_object td, table.cfdump_binary td, table.cfdump_udf td, table.cfdump_udfbody td, table.cfdump_udfarguments td {
						padding: 3px !important;
						background: #ffffff !important;
						vertical-align : top !important;
					}
					table.cfdump_wddx { background: #000000 !important; }
					table.cfdump_wddx th.wddx { background: #444444 !important; }
					table.cfdump_xml { background: #888888 !important; }
					table.cfdump_xml th.xml { background: #aaaaaa !important; }
					table.cfdump_xml td.xml { background: #dddddd !important; }
					table.cfdump_struct { background: #0000cc  !important; }
					table.cfdump_struct th.struct { background: #4444cc !important; }
					table.cfdump_struct td.struct { background: #ccddff !important; }
					table.cfdump_varundefined { background: #CC3300 !important; }
					table.cfdump_varundefined th.varundefined { background: #CC3300 !important; }
					table.cfdump_varundefined td.varundefined { background: #ccddff !important; }
					table.cfdump_array { background: #006600 !important; }
					table.cfdump_array th.array { background: #009900 !important; }
					table.cfdump_array td.array { background: #ccffcc !important; }
					table.cfdump_query { background: #884488 !important; }
					table.cfdump_query th.query { background: #aa66aa !important; }
					table.cfdump_query td.query { background: #ffddff !important; }
					table.cfdump_cfc { background: #ff0000 !important; }
					table.cfdump_cfc th.cfc{ background: #ff4444 !important; }
					table.cfdump_cfc td.cfc { background: #ffcccc !important; }
					table.cfdump_object { background : #ff0000 !important; }
					table.cfdump_object th.object{ background: #ff4444 !important; }
					table.cfdump_binary { background : #eebb00 !important; }
					table.cfdump_binary th.binary { background: #ffcc44 !important; }
					table.cfdump_binary td { font-size: x-small !important; }
					table.cfdump_udf { background: #aa4400 !important; }
					table.cfdump_udf th.udf { background: #cc6600 !important; }
					table.cfdump_udfarguments { background: #dddddd !important; cell-spacing: 3; }
					table.cfdump_udfarguments th { background: #eeeeee !important; color: #000000 !important; }
					table.logData th { background: #000000 !important; color: #ffffff !important; }
				</style>
				<cfif logsExist()>
					<ul>
						<li><a href="generic.cfm?event=logViewer-dash&owner=LogViewer&selected=logViewer-dash&clear=true" style="color:red;">Clear logs</a></li>
					</ul>
					<br/>
					<cfset local.logs = getManager().getLogsManager().search() />
						<cfoutput>
						<cfloop from="1" to="#arrayLen(local.logs)#" index="local.i">
							<cfset local.rowid = createUUID() />
							<table style="width: 100%" class="logData">
								<tr>
									<th>Category</th>
									<th>Level</th>
									<th>Date/Time</th>
									<th>Owner</th>
								</tr>
								<tr id="#local.rowid#" class="collapsable">
									<td>#local.logs[local.i].category#</td>
									<td>#local.logs[local.i].level#</td>
									<td>#local.logs[local.i].logged_on#</td>
									<td>#local.logs[local.i].owner#</td>
								</tr>
							</table>
							<strong>Error Detail:</strong><br/>
							#local.logs[local.i].message#
						</cfloop>
						</cfoutput>
					</table>
				<cfelse>
					<ul>
						<li>No logs! Woohoo!</li>
					</ul>
				</cfif>
			</cfsavecontent>

			<!--- change message --->
			<cfset data.message.setTitle("Log Viewer") />
			<cfset data.message.setData(page) />
		</cfif>

		<cfreturn arguments.event />
	</cffunction>

	<cffunction name="logsExist" access="private" output="false" returntype="boolean">
		<cfreturn yesNoFormat(getManager().getLogsManager().getLogCount()) />
	</cffunction>
	<cffunction name="clearLogs" access="private" output="false" returnType="void">
		<!--- delete everything --->
		<cfset getManager().getLogsManager().deleteByCriteria() />
	</cffunction>

</cfcomponent>