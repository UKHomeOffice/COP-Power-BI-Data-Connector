# Power BI Data Connector
Data Connectors for Power BI enable developers to connect to custom data sources. This data connector enables Power BI Desktop users to connect and authenticate with Home Office APIs that are secured with OAuth 2.0 provided by Keycloak. The token endpoints have been removed from the code for security. The token endpoints need adding in lines 7-12 of the REST_API_Keycloak.pq file. The Git repo contains the source code. The source code is compiled in Visual Studio to produce the data connector .mez file.
## Develop, Compile and Install the Data Connector
1. Install Visual Studio 2019 and install the Power Query SDK from the Visual Studio Marketplace
2. Open the solution by opening the REST API Keycloak.sln file
3. Build the project. This produces an extension file under the project bin\debug folder.
4. Copy the REST API Keycloak.mek extension file into the `[Documents]\Power BI Desktop\Custom Connectors` directory on a computer running Power BI Desktop
5. Open Power BI Desktop and the connector will appear in the 'Other' category

Note, to load extensions that have not been certified by Microsoft, you will need to lower the security level for extensions in Power BI Desktop to enable loading unsigned/uncertified connectors.

1. Go to File | Options and settings | Options
2. Go the Security tab
3. Under *Data Extensions*, select *Allow any extension to load without warning or validation*
4. Restart Power BI Desktop

See the [Connector Certification](https://docs.microsoft.com/en-us/power-query/connectorcertification) documentation
for details on the certification process and requirements.
## Power BI Service Scheduled/On-Demand Refresh
The Power BI Data Gateway is required in order to refresh reports that are published to the Power BI service that were built using the data gateway. Please see the [Technical Documentation](https://docs.microsoft.com/en-us/power-bi/service-gateway-custom-connectors) for more details.
## Issues
Issues can be reported through Microsoft's [Github issues page](https://github.com/Microsoft/DataConnectors/issues).
