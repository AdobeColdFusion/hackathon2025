component cfgrid{
    /*******************************************************

    Function takes in a CSV or query and displays the data in a table

    Takes the following parameters:
        SearchOn = true/false (optional, defaults to false)
        CSVFile = string (optional, defaults to "")
        Pagination = true/false  (optional, defaults to false)
        PaginationNumber = number (optional, defaults to 10)
        DataType = string (optional, defaults to csv)
        csvObjQuery = query (optional, defaults to queryNew(""))
        Sort = true/false (optional, defaults to false)

    *******************************************************/

    function cfgrid(
        boolean SearchOn=false, 
        string CSVFile = "", 
        boolean Pagination = false,
        boolean PaginationNumber = 10,
        string DataType = "csv",
        query csvObjQuery = queryNew(""),
        boolean Sort = false 
        )
        {
        uniqueWrapperID = randRange(10000, 99999); // Create a unique ID for the wrapper div since GridJS requires a unique ID per container
        // Inject Styles for grid component
        writeOutput("<link href='https://cdn.jsdelivr.net/npm/gridjs/dist/theme/mermaid.min.css' rel='stylesheet' />")
        // Create scaffolding for HTML output
        writeOutput("<div id='#uniqueWrapperID#'></div>")
        // Inject base JS for GridJS
        writeOutput("<script src='https://cdn.jsdelivr.net/npm/gridjs/dist/gridjs.umd.js'></script>");
        switch (DataType){
            case "csv":
                try{
                    var CSVData = ReturnHeaderlessCSV(CSVFile); // Read the CSV
                    var headerText = returnHeaderText(CSVFile, CSVData, DataType); // Get the headers
                    csvObj = CSVData; // Set the CSV object
                    returnTableText(CSVFile, CSVData, DataType, SearchOn, Sort, Pagination, PaginationNumber); 
                }
                catch(any e){
                    writeDump(e); 
                    abort;
                    // Handle the error
                }
                break;    
            case "query":
                CSVData = csvObjQuery;
                var headerText = returnHeaderText(CSVFile, CSVData, DataType);
                returnTableText(CSVFile, CSVData, DataType, SearchOn, Sort, Pagination, PaginationNumber); 
                break;
        }
          
        
    }
    public function ReturnHeaderlessCSV(required string CSVFile){
        theCSVFile = getDirectoryFromPath(GetCurrentTemplatePath()) & CSVFile; // Grab the value of the location of the file
            format = "query"; // Set format type.
            csvObj = csvread(filepath = theCSVFile, outputformat = format); // Read CSV into memory
            QueryMetaDataArray = GetMetaData(csvObj); // Since we don't know the structure, we need the meta data.
            GetQueryColCount = arrayLen(QueryMetaDataArray); //Get the length of the meta data array for the query
            headerArray=[]; // Scaffold the header array
            for (row in csvObj){ // Loop through every position in the csvObj query object
                if (csvObj.currentRow > 1){ // Test whether we are on the first row (assuming headers are in first record). 
                    break; // If not, break loop.
                }
                for (colname in QueryMetaDataArray) // Loop through the meta data to get the total number of columns. Use that info to create a header array.
                    {
                        colnameeach = colname.Name; // Grab the column name from the struct
                        colvalue = csvObj[colnameeach][csvObj.currentRow]; // Grab the value in the first row at that column position
                        colvalue = replace(colvalue, '_', ' ', 'all');
                        arrayAppend(headerArray, "#colvalue#"); // Append it to our header array
                    }
            }
            readconfiguration={ "header"=#headerArray#, "skipHeaderRecord" = 1 } // Set csvformat to header info, ignore header row
            csvForOutput = csvread(filepath = theCSVFile, outputformat = format, csvformatconfiguration = readconfiguration); // Re-read the CSV, but this time set the headers correctly and ignore the first row
            return csvForOutput;
    }
    public function returnHeaderText(CSVFile, QueryData, required string DataType){
        if (DataType == "csv"){
            theCSVFile = getDirectoryFromPath(GetCurrentTemplatePath()) & CSVFile; // Grab the value of the location of the file
            format = "query"; // Set format type.
            csvObj = csvread(filepath = theCSVFile, outputformat = format); // Read CSV into memory
            QueryMetaDataArray = GetMetaData(csvObj); // Since we don't know the structure, we need the meta data.
            GetQueryColCount = arrayLen(QueryMetaDataArray); //Get the length of the meta data array for the query
            headerText = ""; // Scaffold the header text
            for (row in csvObj){ // Loop through every position in the csvObj query object
                if (csvObj.currentRow > 1){ // Test whether we are on the first row (assuming headers are in first record). 
                    break; // If not, break loop.
                }
                for (colname in QueryMetaDataArray) // Loop through the meta data to get the total number of columns. Use that info to create a header array.
                    {
                        colnameeach = colname.Name; // Grab the column name from the struct
                        colvalue = csvObj[colnameeach][csvObj.currentRow]; // Grab the value in the first row at that column position
                        colvalue = replace(colvalue, '_', ' ', 'all');
                        colvalueArray = ListToArray(colvalue, " ");
                        placeholder = "";
                        for (word in colvalueArray){
                            tempWord = "";
                            upcasedword = uCase(left(word, 1)) & right(word, len(word) - 1);
                            tempWord = upcasedword & " " ;
                            placeholder &= tempWord;
                        }
                        headerText &= '"#placeholder#",';                        
                    }    
            }
        }
        else if (DataType == "query"){
            QueryMetaDataArray = GetMetaData(QueryData); // Since we don't know the structure, we need the meta data.
            GetQueryColCount = arrayLen(QueryMetaDataArray); //Get the length of the meta data array for the query
            headerText = ""; // Scaffold the header text
            for (item in QueryMetaDataArray) // Loop through the meta data to get the total number of columns. Use that info to create a header array.
                {
                    colnameeach = item.Name; // Grab the column name from the struct
                    colvalue = replace(colnameeach, '_', ' ', 'all');
                    colvalueArray = ListToArray(colvalue, " ");
                    placeholder = "";
                    for (word in colvalueArray){
                        tempWord = "";
                        upcasedword = uCase(left(word, 1)) & right(word, len(word) - 1);
                        tempWord = upcasedword & " " ;
                        placeholder &= tempWord;
                    }
                    headerText &= '"#placeholder#",'; 
                }   
        }
        return headerText;
    }
    public function returnTableText(CSVFile, CSVData, required string DataType, SearchOn, Sort, Pagination, PaginationNumber){
        var GridText = ''; 
        var dataText = "";
        GridText &= '<script>new gridjs.Grid({columns: [';   
        QueryMetaDataArray = GetMetaData(CSVData); // Since we don't know the structure, we need the meta data.
        GridText &= headerText;
        GridText &= '],';
        GridText &= 'data: [';

        if(DataType == "csv"){
        for (row in CSVData){
            dataText &= "["
            if (CSVData.currentRow == 1){ // Test whether we are on the first row (assuming headers are in first record). 
                // Do nothing in the first row
            }
            for (colname in QueryMetaDataArray) // Loop through the meta data to get the total number of columns. Use that info to create a header array.
                {
                    colnameeach = colname.Name; // Grab the column name from the struct
                    colvalue = CSVData[colnameeach][CSVData.currentRow]; // Grab the value in the first row at that column position
                    dataText &= '"#colvalue#",';
                }
                dataText &= '],';
        }
        
        
        }
        else if (DataType == "query"){
            for (row in CSVData){
            dataText &= "["
            if (CSVData.currentRow == 1){ // Test whether we are on the first row (assuming headers are in first record). 
                // Do nothing in the first row
            }
            for (colname in QueryMetaDataArray) // Loop through the meta data to get the total number of columns. Use that info to create a header array.
                {
                    colnameeach = colname.Name; // Grab the column name from the struct
                    colvalue = CSVData[colnameeach][CSVData.currentRow]; // Grab the value in the first row at that column position
                    dataText &= '"#colvalue#",';
                }
                dataText &= '],';
        }
        }
        GridText &= dataText;
        GridText &= ']'; 
            if(SearchOn){
                GridText &= ',search: true';    
            }
            if(Sort){
                GridText &= ',sort: true';}
            if(pagination){
                GridText &= ',pagination: {'
                GridText &= 'limit: #PaginationNumber#,'
                GridText &= 'summary: false'
                GridText &= '}'
            }
        GridText &= '}).render(document.getElementById("#uniqueWrapperID#"));';
        GridText &= '</script>'; 
        writeOutput(GridText);
    }
}