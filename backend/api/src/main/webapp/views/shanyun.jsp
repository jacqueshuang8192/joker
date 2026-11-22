<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>支付接口</title>
</head>
<body>
	<form id="myfrom" name="myfrom" method="post" onsubmit="return sumbitTest();" action='<%=request.getAttribute("url")%>'>
		<%= request.getAttribute("input")%>
	</form>
	<script language="JavaScript" type="text/javascript">
		setTimeout("document.myfrom.submit()", 100); //此处为1秒提交，可更改为立刻提交。
	</script>
</body>
</html>