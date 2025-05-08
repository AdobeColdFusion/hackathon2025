<cfscript>
// Create fake data for testing
numRows = 90;
fakeQuery = queryNew("planet_name,visitors_today,is_habitable,gravity_index,last_contact", "VarChar,Integer,Integer,Integer,Date");
planets = ["Zebulon", "Krylon", "Xantar", "Orbis", "Thalassa", "Virelia", "Draconis", "Mira", "Epsilon", "NovaPrime"];
for (i = 1; i <= numRows; i++) {
    row = {
        planet_name: planets[randRange(1, arrayLen(planets))],
        visitors_today: randRange(0, 10000),
        is_habitable: randRange(1, 2) EQ 1, // true or false
        last_contact: randRange(1, 2) EQ 1, // true or false
        gravity_index: numberFormat(randRange(5, 25) / 10, "9.9"), // float between 0.5 and 2.5
        last_contact: dateAdd("d", -randRange(0, 30), now()) // random date within last 30 days
    };
    queryAddRow(fakeQuery);
    querySetCell(fakeQuery, "planet_name", row.planet_name, i);
    querySetCell(fakeQuery, "visitors_today", row.visitors_today, i);
    querySetCell(fakeQuery, "is_habitable", row.is_habitable, i);
    querySetCell(fakeQuery, "gravity_index", row.gravity_index, i);
    querySetCell(fakeQuery, "last_contact", row.last_contact, i);
}
</cfscript>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>Adobe ColdFusion 2025 - CFGrid Demo</title>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="[https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&display=swap"](https://fonts.googleapis.com/css2?family=Open+Sans:wght@400;600;700&display=swap") rel="stylesheet">
    <style>
        * {
            font-family: 'Open Sans', sans-serif;
        }
    </style>
</head>
    <body>
<h1>CFGrid Component</h1>
<cfscript>
    // This file is loaded to display the contents of the data directory, which are CSVs
    obj = createObject("component","cfgrid");
    writeOutput("<h2>CSV Table</h3>");
    invoke(obj,"cfgrid",{SearchOn = true, DataType = "csv", CSVFile = "data\purchase_orders.csv",Pagination = true, Sort = true, PaginationNumber = 5});
    writeOutput("<h2>Query Table</h3>");
    invoke(obj,"cfgrid",{SearchOn = true, DataType = "query", csvObjQuery = fakeQuery,Pagination = true, Sort = true, PaginationNumber = 5});
</cfscript>
</body>
</html>