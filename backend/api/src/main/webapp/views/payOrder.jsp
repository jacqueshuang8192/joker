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
        <input type="test" name="pay_memberid" value="${pay_memberid}" />
        <input type="test" name="pay_orderid" value="${pay_orderid}" />
        <input type="test" name="pay_amount" value="${pay_amount}" />
        <input type="test" name="pay_applydate" value="${pay_applydate}" />
        <input type="test" name="pay_bankcode" value="${pay_bankcode}" />
        <input type="test" name="pay_notifyurl" value="${pay_notifyurl}" />
        <input type="test" name="pay_callbackurl" value="${pay_callbackurl}" />
        <input type="test" name="tongdao" value="${tongdao}" />
        <input type="test" name="pay_md5sign" value="${pay_md5sign}" />
        <input type="submit" name="sub" id="sub" value="sub"/>
    </form>
</div>
<script>
    $(document).ready(function () {
        $("#sub").click();
    })
</script>
</body>

</html>
