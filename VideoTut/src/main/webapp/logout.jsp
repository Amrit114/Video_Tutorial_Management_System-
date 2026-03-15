<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Logging Out...</title>
</head>
<body>
<%
session.invalidate();
response.sendRedirect("homepage/index.jsp");
%>
</body>
</html>
