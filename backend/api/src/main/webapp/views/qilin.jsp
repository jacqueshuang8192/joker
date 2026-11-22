<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <script src="../js/jquery-2.1.4.min.js" type="text/javascript"></script>
    <script src="../js/qrcode.js" type="text/javascript"></script>
</head>
<body>
<div>
    <div id="qrcode"></div>
    <form id="Form1" name="Form1" method="post" action="https://pay.qilinpay-api.com">

            <input hidden name="uid"  value="${uid}"  />
            <input hidden name="price"  value="${price}"/>
            <input hidden name="istype" value="${istype}" />
            <input hidden name="notify_url"  value="${notify_url}" />
            <input hidden name="return_url"  value="${return_url}"/>
            <input hidden name="orderid"  value="${orderid}"/>
            <input hidden name="version" value="${version}"/>
            <input hidden name="goodsname"  value="${goodsname}" />
            <input hidden name="orderuid"  value="${orderuid}" />
            <input hidden name="key"  value="${key}" />

            <input type="submit" id="sub" value="sub"/>

    </form>
</div>
<script>
    $(document).ready(function () {
        $("#sub").click();
    })
</script>
</body>

</html>
