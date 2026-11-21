<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <script src="../js/jquery-2.1.4.min.js" type="text/javascript"></script>
    <script src="../js/qrcode.js" type="text/javascript"></script>
</head>
<body>
<div>
    请保存此二维码并用微信识别此二维码进行支付
    <div id="qrcode"></div>
    <form id="Form1" name="Form1" method="post" action="${url}">
        <input type="text" name="gameOrderId" value="${gameOrderId}" hidden />
        <input type="text" name="serverId" value="${serverId}" hidden/>
        <input type="text" name="userId" value="${userId}" hidden/>
        <input type="text" name="pay_money" value="${pay_money}" hidden/>
        <input type="text" name="recharge_gold" value="${recharge_gold}" hidden/>
        <input type="text" name="channel_num" value="${channel_num}" hidden />
        <input type="text " name="payType" value="${payType }" hidden/>
        <input type="text" name="gameNotifyUrl" value="${gameNotifyUrl}" hidden/>
        <input type="text" name="sign" value="${sign}" hidden/>
        <input type="submit" id="sub"/>
    </form>
</div>
<%--<script>--%>
    <%--$(document).ready(function () {--%>
        <%--$("#sub").click();--%>
    <%--})--%>
<%--</script>--%>
</body>

</html>
