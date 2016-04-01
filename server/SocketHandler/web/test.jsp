<%-- 
    Document   : test
    Created on : Mar 29, 2016, 10:22:46 AM
    Author     : davidboschwitz
--%>

<%@page import="gameconnect.server.MessageType"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Hello World!</h1>
        <% out.print(MessageType.CHAT_MESSAGE); %>
    </body>
</html>
